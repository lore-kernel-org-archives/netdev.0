From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: netdevice: Kill 'feature' test macros.
Date: Tue, 12 Jul 2011 21:06:21 +0200
Message-ID: <201107122106.21570.arnd@arndb.de>
References: <20110712.105005.34046159802896038.davem@davemloft.net> <20110712111033.6e3923db@nehalam.ftrdhcpuser.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.187]:57874 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753709Ab1GLTHF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Jul 2011 15:07:05 -0400
In-Reply-To: <20110712111033.6e3923db@nehalam.ftrdhcpuser.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 12 July 2011 20:10:33 Stephen Hemminger wrote:
> On Tue, 12 Jul 2011 10:50:05 -0700 (PDT)
> David Miller <davem@davemloft.net> wrote:
> 
> > 
> > Almost all of these have long outstayed their welcome.
> > 
> > And for every one of these macros, there are 10 features for which we
> > didn't get macros added.
> > 
> > Let's just delete them all, and get out of habit of doing things this
> > way.
> > 
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>
> 
> This is sure to break out of tree drivers...

I guess that's a good thing, but it also breaks these:

drivers/staging/wlags49_h2/wl_internal.h:#ifdef HAVE_NETDEV_PRIV
drivers/net/cxgb4vf/cxgb4vf_main.c:#ifdef HAVE_NET_DEVICE_OPS
drivers/staging/ft1000/ft1000-usb/ft1000_hw.c:#ifdef HAVE_NET_DEVICE_OPS
net/batman-adv/soft-interface.c:#ifdef HAVE_NET_DEVICE_OPS

Acked-by: Arnd Bergmann <arnd@arndb.de>

if the above are taken care of.
