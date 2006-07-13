From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: [PATCH 2/2] correct dev_alloc_skb kerneldoc
Date: Thu, 13 Jul 2006 13:47:11 -0700
Message-ID: <20060713134711.c6a0a758.rdunlap@xenotime.net>
References: <20060707155255.10f2e10f@dxpl.pdx.osdl.net>
	<20060707.165527.77037268.davem@davemloft.net>
	<20060708104811.GB31751@lst.de>
	<20060708.133738.123994596.davem@davemloft.net>
	<20060713203615.GA26954@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shemminger@osdl.org, netdev@vger.kernel.org,
	support@pathscale.com, samuel@sortiz.org, kkeil@suse.de,
	kai.germaschewski@gmx.de, chas@cmf.nrl.navy.mil, paulus@samba.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenotime.net ([66.160.160.81]:53460 "HELO xenotime.net")
	by vger.kernel.org with SMTP id S1030367AbWGMUoX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2006 16:44:23 -0400
Received: from midway.site ([71.117.253.75]) by xenotime.net for <netdev@vger.kernel.org>; Thu, 13 Jul 2006 13:44:22 -0700
To: Christoph Hellwig <hch@lst.de>
In-Reply-To: <20060713203615.GA26954@lst.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 13 Jul 2006 22:36:16 +0200 Christoph Hellwig wrote:

...
> 
> I gave converting the dev_alloc_skb prototype everywhere a spin and it
> doesn't look too bad.  There's only a few places that don't have a
> netdevice at hand, and all these look bogus:
> 
...

>  - drivers/infiniband/hw/ipath/ipath_driver.c:
>    	Uses skbbuffs in a driver that has absolutely nothing to do
> 	with networking.  Duh..

Doesn't using netlink at all have that same effect?  (using skbs
in some code that may have nothing to do with networking)

Or should netlink be limited in its scope?

---
~Randy
