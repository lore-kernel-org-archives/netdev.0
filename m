From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH next] staging-p80211: Kill directly reference of
	netdev->priv
Date: Fri, 5 Dec 2008 07:44:46 -0800
Message-ID: <20081205154446.GB28030@suse.de>
References: <4939456D.8010003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42945 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756114AbYLEP6O (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 10:58:14 -0500
Content-Disposition: inline
In-Reply-To: <4939456D.8010003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 05, 2008 at 11:14:53PM +0800, Wang Chen wrote:
> In this driver, netdev's private data is wlandevice_t.
> And the wlandev(type of wlandevice_t) is exist before netdev be allocated.
> So use netdev->ml_priv to point to the private data.
> 
> I am not sure whether I should consider the kernel version older than 2.3.38.
> Because in those kernels, netdevice_t is "structure dev" instead of 
> "structure net_device" and of course "dev->ml_priv" will cause compile error.
> But before my patch, in function wlan_setup(), there is a ether_setup(net_device)
> which already broke kernels which older than 2.3.38.

Heh, no we only need to support the current mainline kernel with this
driver, no old 2.3.x versions :)

thanks for the patch, I'll queue it up,

greg k-h
