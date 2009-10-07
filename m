From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] add vif using local interface index instead of IP
Date: Wed, 07 Oct 2009 01:23:41 -0700 (PDT)
Message-ID: <20091007.012341.70851712.davem@davemloft.net>
References: <1b9338490909160853u4d90093fg56453ffff5a67ced@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: opurdila@ixiacom.com, netdev@vger.kernel.org
To: mail4ilia@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36033
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756775AbZJGIXq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 04:23:46 -0400
In-Reply-To: <1b9338490909160853u4d90093fg56453ffff5a67ced@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Ilia K." <mail4ilia@gmail.com>
Date: Wed, 16 Sep 2009 18:53:07 +0300

> When routing daemon wants to enable forwarding of multicast traffic it
> performs something like:
 ...
> This leads (in the kernel) to calling  vif_add() function call which
> search the (physical) device using assigned IP address:
>        dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr);
> 
> The current API (struct vifctl) does not allow to specify an
> interface other way than using it's IP, and if there are more than a
> single interface with specified IP only the first one will be found.
> 
> The attached patch (against 2.6.30.4) allows to specify an interface
> by its index, instead of IP address:
...
> Signed-off-by: Ilia K. <mail4ilia@gmail.com>

Applied, thank you.
