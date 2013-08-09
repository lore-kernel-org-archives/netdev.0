From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 2/2] net: asix: Move declaration of ax88172a_info to
 shared header
Date: Fri, 9 Aug 2013 10:40:16 -0700
Message-ID: <20130809104016.236fcd9d@nehalam.linuxnetplumber.net>
References: <1376069482-16951-1-git-send-email-broonie@kernel.org>
	<1376069482-16951-2-git-send-email-broonie@kernel.org>
	<CAOMZO5AHVcmb8DiqM_H12e9cD3zAt0ZGz8yrLDyq5FwwO+cSMA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Mark Brown <broonie@kernel.org>,
	"David S. Miller" <davem@davemloft.net>, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linaro-kernel@lists.linaro.org,
	Mark Brown <broonie@linaro.org>
To: Fabio Estevam <festevam@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:61756 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758451Ab3HIRkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Aug 2013 13:40:21 -0400
Received: by mail-pa0-f45.google.com with SMTP id bg4so5167374pad.18
        for <netdev@vger.kernel.org>; Fri, 09 Aug 2013 10:40:20 -0700 (PDT)
In-Reply-To: <CAOMZO5AHVcmb8DiqM_H12e9cD3zAt0ZGz8yrLDyq5FwwO+cSMA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 9 Aug 2013 14:39:06 -0300
Fabio Estevam <festevam@gmail.com> wrote:

> On Fri, Aug 9, 2013 at 2:31 PM, Mark Brown <broonie@kernel.org> wrote:
> > From: Mark Brown <broonie@linaro.org>
> >
> > Ensure that the definition of ax88172a_info matches the declaration seen
> > by users and silence sparse warnings about symbols without declarations
> > in the global namespace by moving the declaration into the shared header
> > asix.h.
> >
> > Signed-off-by: Mark Brown <broonie@linaro.org>
> > ---
> >  drivers/net/usb/asix.h         | 2 ++
> >  drivers/net/usb/asix_devices.c | 2 --
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/net/usb/asix.h b/drivers/net/usb/asix.h
> > index 346c032..bdaa12d 100644
> > --- a/drivers/net/usb/asix.h
> > +++ b/drivers/net/usb/asix.h
> > @@ -178,6 +178,8 @@ struct asix_common_private {
> >         struct asix_rx_fixup_info rx_fixup_info;
> >  };
> >
> > +extern const struct driver_info ax88172a_info;
> 
> You could drop the 'extern' here.
> 
> All other function prototypes in this header file do not use 'extern'.

That is data, not function prototype, so yes extern is needed.
