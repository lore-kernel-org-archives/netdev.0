From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: Add fib rules at vrf device create
Date: Tue, 08 Dec 2015 22:41:00 -0500 (EST)
Message-ID: <20151208.224100.1951416968376650648.davem@davemloft.net>
References: <20151208.214411.2137019448940208712.davem@davemloft.net>
	<56679B2F.5080700@cumulusnetworks.com>
	<56679E4F.3020908@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shm@cumulusnetworks.com
To: dsa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49554 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751294AbbLIDlC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2015 22:41:02 -0500
In-Reply-To: <56679E4F.3020908@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsa@cumulusnetworks.com>
Date: Tue, 8 Dec 2015 20:21:51 -0700

> On 12/8/15 8:08 PM, David Ahern wrote:
>> root@kenny-jessie2:~# ip ru add oif vrf-red lookup vrf-red
>>
>> root@kenny-jessie2:~# ip ru ls
>> 0:    from all lookup local
>> 32759:    from all oif vrf-red lookup vrf-red
>> 32760:    from all iif vrf-green lookup vrf-green
>> 32761:    from all oif vrf-green lookup vrf-green
>> 32762:    from all iif vrf-blue lookup vrf-blue
>> 32763:    from all oif vrf-blue lookup vrf-blue
>> 32764:    from all iif vrf-red lookup vrf-red
>> 32765:    from all oif vrf-red lookup vrf-red
>> 32766:    from all lookup main
>> 32767:    from all lookup default
> 
> d'oh. They don't fail in the sense of a user getting an error message
> but they add duplicate entries. So, if I fix the duplicity (ie., don't
> add a second one) would the patch be acceptable?

No, people need to issue all the commands in order for the configuration
to work in all kernels.
