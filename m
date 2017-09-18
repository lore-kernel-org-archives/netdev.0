From: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
Subject: Re: [PATCH v06 35/36] uapi linux/tls.h: don't include <net/tcp.h> in
 user space
Date: Mon, 18 Sep 2017 15:57:35 +0300
Message-ID: <20170918125735.GA13389@lakka.kapsi.fi>
References: <20170806164428.2273-1-mikko.rapeli@iki.fi>
 <20170806164428.2273-36-mikko.rapeli@iki.fi>
 <20170808232554.GK10552@altlinux.org>
 <20170904161510.GA16001@altlinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Dave Watson <davejwatson-b10kYP2dOMg@public.gmane.org>,
        Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Aviad Yehezkel <aviadye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "Dmitry V. Levin" <ldv-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170904161510.GA16001-u2l5PoMzF/Vg9hUCZPvPmw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 04, 2017 at 07:15:11PM +0300, Dmitry V. Levin wrote:
> On Wed, Aug 09, 2017 at 02:25:54AM +0300, Dmitry V. Levin wrote:
> > On Sun, Aug 06, 2017 at 06:44:26PM +0200, Mikko Rapeli wrote:
> > > It is not needed and not part of uapi headers, but causes
> > > user space compilation error:
> > > 
> > > fatal error: net/tcp.h: No such file or directory
> > >  #include <net/tcp.h>
> > >                      ^
> > > 
> > > Signed-off-by: Mikko Rapeli <mikko.rapeli-X3B1VOXEql0@public.gmane.org>
> > > Cc: Dave Watson <davejwatson-b10kYP2dOMg@public.gmane.org>
> > > Cc: Ilya Lesokhin <ilyal-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > Cc: Aviad Yehezkel <aviadye-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > > ---
> > >  include/uapi/linux/tls.h | 2 ++
> > >  1 file changed, 2 insertions(+)
> > > 
> > > diff --git a/include/uapi/linux/tls.h b/include/uapi/linux/tls.h
> > > index cc1d21db35d8..d87c698623f2 100644
> > > --- a/include/uapi/linux/tls.h
> > > +++ b/include/uapi/linux/tls.h
> > > @@ -37,7 +37,9 @@
> > >  #include <asm/byteorder.h>
> > >  #include <linux/socket.h>
> > >  #include <linux/tcp.h>
> > > +#ifdef __KERNEL__
> > >  #include <net/tcp.h>
> > > +#endif
> > 
> > Let's move it to include/net/tls.h instead.
> 
> So everybody ignored this and *new* uapi header was released
> in a totally unusable form along with v4.13.

Should issues like these be filed into bugzilla instead?

Maybe emails are easier to ignore than bugzilla tickets.

-Mikko
