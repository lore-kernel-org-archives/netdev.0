From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Mon, 11 Apr 2011 07:50:03 -0700
Message-ID: <4DA3151B.4030507@intel.com>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>	 <1302167168.3357.12.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>	 <1302253651.4409.2.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>	 <1302267400.4409.22.camel@edumazet-laptop>	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>	 <1302275223.4409.36.camel@edumazet-laptop>	 <D12
 839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se> <1302330998.2656.113.camel@edumazet-laptop> <D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:17233 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752076Ab1DKOuE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Apr 2011 10:50:04 -0400
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/10/2011 12:02 AM, Wei Gu wrote:
> Hi , I haven't enable the packet header spilting, so I think no
> netdev_alloc_page() will be called in my case.
>
> BTW, I also did the same test from 2.6.33 to 2.6.35 kernel, looks the
> problem happens from 2.6.35, cause 2.6.32/33/34 do not see this
> problem at all, they all works pretty good.
>
> I modify the .configs base on the FC13/14, and also manully set the
> DMAR DEFAULT to off, chose the SLAB as the memory allocator (same as
> RHEL6 2.6.32). For more detail about the config, please check the
> attached file
>
> Thanks WeiGu

WeiGu,

In order to try and isolate this issue I was wondering if you could try 
our out-of-tree ixgbe driver from e1000.sf.net?  The idea would be to 
test it on 2.6.34 and 2.6.35 in order to determine if the issue is due 
to a change in the kernel or a change in the driver.  If the performance 
is the same on these two kernels with our out-of-tree driver then we 
know the issue is a change somewhere in the ixgbe driver in the kernel.

Thanks,

Alex

