From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 2/2] net: asix: Move declaration of ax88172a_info to
 shared header
Date: Fri, 09 Aug 2013 10:50:36 -0700
Message-ID: <1376070636.20509.4.camel@edumazet-glaptop>
References: <1376069482-16951-1-git-send-email-broonie@kernel.org>
	 <1376069482-16951-2-git-send-email-broonie@kernel.org>
	 <CAOMZO5AHVcmb8DiqM_H12e9cD3zAt0ZGz8yrLDyq5FwwO+cSMA@mail.gmail.com>
	 <20130809104016.236fcd9d@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linaro-kernel-cunTk1MwBs8s++Sfvej+rw@public.gmane.org,
	Mark Brown <broonie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20130809104016.236fcd9d-We1ePj4FEcvRI77zikRAJc56i+j3xesD0e7PPNI6Mm0@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, 2013-08-09 at 10:40 -0700, Stephen Hemminger wrote:
> On Fri, 9 Aug 2013 14:39:06 -0300
> Fabio Estevam <festevam-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> wrote:
> 
> > On Fri, Aug 9, 2013 at 2:31 PM, Mark Brown <broonie-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
> > > From: Mark Brown <broonie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > >
> > > Ensure that the definition of ax88172a_info matches the declaration seen
> > > by users and silence sparse warnings about symbols without declarations
> > > in the global namespace by moving the declaration into the shared header
> > > asix.h.
> > >
> > > Signed-off-by: Mark Brown <broonie-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>
> > > ---
> > >  drivers/net/usb/asix.h         | 2 ++
> > >  drivers/net/usb/asix_devices.c | 2 --
> > >  2 files changed, 2 insertions(+), 2 deletions(-)
> > >
> > > diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
> > > index 346c032..bdaa12d 100644
> > > --- a/drivers/net/usb/asix.h
> > > +++ b/drivers/net/usb/asix.h
> > > @@ -178,6 +178,8 @@ struct asix_common_private {
> > >         struct asix_rx_fixup_info rx_fixup_info;
> > >  };
> > >
> > > +extern const struct driver_info ax88172a_info;
> > 
> > You could drop the 'extern' here.
> > 
> > All other function prototypes in this header file do not use 'extern'.
> 
> That is data, not function prototype, so yes extern is needed.


And this kind of contradictions show why extern declarations make sense
in include files, for text or/and data.

Some compiler folk decided 'extern' were not mandatory for code, but its
really adding confusion and endless discussions.



--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
