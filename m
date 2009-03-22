From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 22/77] usbnet: convert catc device to net_device_ops
Date: Sat, 21 Mar 2009 19:40:22 -0700 (PDT)
Message-ID: <20090321.194022.229105707.davem@davemloft.net>
References: <20090321053527.316395697@vyatta.com>
	<20090321053714.207963951@vyatta.com>
	<20090321101728.GA3380@psychotron.englab.brq.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, dbrownell@users.sourceforge.net,
	netdev@vger.kernel.org
To: jpirko@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751892AbZCVCkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2009 22:40:35 -0400
In-Reply-To: <20090321101728.GA3380@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jpirko@redhat.com>
Date: Sat, 21 Mar 2009 11:17:29 +0100

> Sat, Mar 21, 2009 at 06:35:49AM CET, shemminger@vyatta.com wrote:
> >Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >
> >--- a/drivers/net/usb/catc.c	2009-03-20 12:10:10.851651580 -0700
> >+++ b/drivers/net/usb/catc.c	2009-03-20 12:10:23.060839265 -0700
> >@@ -743,6 +743,18 @@ static int catc_stop(struct net_device *
> > 	return 0;
> > }
> > 
> >+static const struct net_device_ops catc_netdev_ops = {
> >+	.ndo_open		= catc_open,
> >+	.ndo_stop		= catc_stop,
> >+	.ndo_start_xmit		= catc_start_xmit,
>                                   ^^^^^^^^^^^^^^^
> Shouldn't be here catc_hard_start_xmit() instead? Cannot find catc_start_xmit()
> anywhere in the code...

It gets renamed to catc_start_xmit() in the previous patch in this
series, #21.
