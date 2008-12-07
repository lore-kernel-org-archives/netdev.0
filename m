From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH next] staging-p80211: Kill directly reference of
 netdev->priv
Date: Sat, 06 Dec 2008 23:58:46 -0800 (PST)
Message-ID: <20081206.235846.265588494.davem@davemloft.net>
References: <4939456D.8010003@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gregkh@suse.de, netdev@vger.kernel.org
To: wangchen@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59417
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753365AbYLGH6p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 7 Dec 2008 02:58:45 -0500
In-Reply-To: <4939456D.8010003@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wang Chen <wangchen@cn.fujitsu.com>
Date: Fri, 05 Dec 2008 23:14:53 +0800

> In this driver, netdev's private data is wlandevice_t.
> And the wlandev(type of wlandevice_t) is exist before netdev be allocated.
> So use netdev->ml_priv to point to the private data.
> 
> I am not sure whether I should consider the kernel version older than 2.3.38.
> Because in those kernels, netdevice_t is "structure dev" instead of 
> "structure net_device" and of course "dev->ml_priv" will cause compile error.
> But before my patch, in function wlan_setup(), there is a ether_setup(net_device)
> which already broke kernels which older than 2.3.38.
> 
> Compile test only.
> 
> Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>

Applied.
