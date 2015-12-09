From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Add fib rules at vrf device create
Date: Tue, 08 Dec 2015 22:40:32 -0500 (EST)
Message-ID: <20151208.224032.2201079065584601145.davem@davemloft.net>
References: <1449607685-8910-1-git-send-email-dsa@cumulusnetworks.com>
	<20151208.214411.2137019448940208712.davem@davemloft.net>
	<56679B2F.5080700@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49549 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751245AbbLIDkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:40:33 -0500
In-Reply-To: <56679B2F.5080700@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 8 Dec 2015 20:08:31 -0700

> On 12/8/15 7:44 PM, David Miller wrote:
>> Unfortunately it's too late for this, you should have considered this
>> issue fully when VRF first went into an upstream release.
>>
>> If I add your change, the user experience is _worse_.
>>
>> Users on older kernels have to use the full sequence, then if they
>> upgrade their kernels to one with this patch then the 'ru add' et
>> al. commands will fail.
>>
> 
> Perhaps this is another fug (feature bug), they do not fail:
> 
> root@kenny-jessie2:~# ip ru ls
> 0:	from all lookup local
> 32760:	from all iif vrf-green lookup vrf-green
> 32761:	from all oif vrf-green lookup vrf-green
> 32762:	from all iif vrf-blue lookup vrf-blue
> 32763:	from all oif vrf-blue lookup vrf-blue
> 32764:	from all iif vrf-red lookup vrf-red
> 32765:	from all oif vrf-red lookup vrf-red
> 32766:	from all lookup main
> 32767:	from all lookup default
> 
> root@kenny-jessie2:~# ip ru add oif vrf-red lookup vrf-red

Grrr...
