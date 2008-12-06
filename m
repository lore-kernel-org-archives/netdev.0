From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: Re: [PATCH next] staging-p80211: Kill directly reference of	c
Date: Sat, 06 Dec 2008 10:28:45 +0800
Message-ID: <4939E35D.4010102@cn.fujitsu.com>
References: <4939456D.8010003@cn.fujitsu.com> <20081205154446.GB28030@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	NETDEV <netdev@vger.kernel.org>
To: Greg KH <gregkh@suse.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:52672 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752860AbYLFC2z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Dec 2008 21:28:55 -0500
In-Reply-To: <20081205154446.GB28030@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greg KH said the following on 2008-12-5 23:44:
> On Fri, Dec 05, 2008 at 11:14:53PM +0800, Wang Chen wrote:
>> In this driver, netdev's private data is wlandevice_t.
>> And the wlandev(type of wlandevice_t) is exist before netdev be allocated.
>> So use netdev->ml_priv to point to the private data.
>>
>> I am not sure whether I should consider the kernel version older than 2.3.38.
>> Because in those kernels, netdevice_t is "structure dev" instead of 
>> "structure net_device" and of course "dev->ml_priv" will cause compile error.
>> But before my patch, in function wlan_setup(), there is a ether_setup(net_device)
>> which already broke kernels which older than 2.3.38.
> 
> Heh, no we only need to support the current mainline kernel with this
> driver, no old 2.3.x versions :)
> 

Thanks for your explanation.

> thanks for the patch, I'll queue it up,
> 

I'm doing this "kill netdev->priv" work on Dave's net-next tree now.
So, will it be better to let Dave apply this to his net-next instead
you apply it?
Just suggestion :)

