From: Ivo van Doorn <ivdoorn@gmail.com>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Sat, 23 Feb 2008 20:50:34 +0100
Message-ID: <200802232050.35157.IvDoorn@gmail.com>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc> <200802232044.59887.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Masakazu Mokuno <mokuno@sm.sony.co.jp>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Sebastian Siewior <netdev@ml.breakpoint.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from el-out-1112.google.com ([209.85.162.178]:30195 "EHLO
	el-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757433AbYBWTu4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 14:50:56 -0500
Received: by el-out-1112.google.com with SMTP id v27so726841ele.23
        for <netdev@vger.kernel.org>; Sat, 23 Feb 2008 11:50:55 -0800 (PST)
In-Reply-To: <200802232044.59887.IvDoorn@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 23 February 2008, Ivo van Doorn wrote:
> On Saturday 23 February 2008, Sebastian Siewior wrote:
> > so select it.
> > Signed-off-by: Sebastian Siewior <sebastian@breakpoint.cc>
> > ---
> >  drivers/net/Kconfig |    1 +
> >  1 files changed, 1 insertions(+), 0 deletions(-)
> > 
> > diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
> > index f337800..a116056 100644
> > --- a/drivers/net/Kconfig
> > +++ b/drivers/net/Kconfig
> > @@ -2363,6 +2363,7 @@ config GELIC_NET
> >  config GELIC_WIRELESS
> >         bool "PS3 Wireless support"
> >         depends on GELIC_NET
> > +       select MAC80211
> >         help
> >          This option adds the support for the wireless feature of PS3.
> >          If you have the wireless-less model of PS3 or have no plan to
> 
> Is there any particular reason why this driver is in drivers/net instead
> of drivers/net/wireless (along with all other wireless drivers?
> 
> Additionally, all other mac80211 drivers depend on mac80211 instead
> of selecting it. So I think for consistency it might be better to also
> make this driver depend on it, rather then selecting.

Additionally, what part of the driver actually uses mac80211?
I just browsed to the code, and it seems to work completely without
using mac80211. Instead it seems to work directly by registering a
net_device structure...

Ivo
