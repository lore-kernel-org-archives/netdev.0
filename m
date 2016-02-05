From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Keystone 2 boards boot failure
Date: Fri, 5 Feb 2016 13:55:37 -0500
Message-ID: <56B4F029.3090804@ti.com>
References: <56B0DE61.2000704@ti.com> <10700980.gTvMTB9pzv@wuerfel>
 <56B15591.7080409@ti.com> <1682165.IJ7dHXqc6L@wuerfel>
 <56B233F3.40000@oracle.com> <56B24B3F.2070906@ti.com>
 <56B25F7C.4060507@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <w-kwok2@ti.com>, <davem@davemloft.net>
To: santosh shilimkar <santosh.shilimkar@oracle.com>,
	Arnd Bergmann <arnd@arndb.de>,
	"Franklin S Cooper Jr." <fcooper@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:52482 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751726AbcBESzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Feb 2016 13:55:46 -0500
In-Reply-To: <56B25F7C.4060507@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2016 03:13 PM, santosh shilimkar wrote:
> On 2/3/2016 10:47 AM, Murali Karicheri wrote:
>> On 02/03/2016 12:08 PM, santosh shilimkar wrote:
>>> On 2/3/2016 8:35 AM, Arnd Bergmann wrote:
> 
> [..]
> 
>>>> It would be nice to give this a go once the network driver problem
>>>> is solved.
>>>>
>>> Big endian kernel has worked on Keystone in past.
>>
>> Yes, this was on a v3.10.x baseline, not in the upstream.
>>
> Thats what I mean in past. That time upstream didn't have
> ARM BE patches o.w there was no other depedency.
> 
>>> Yes, above secondary hook needs to be modified along with
>>> drivers endian macro conversion was what was needed IIRC.
>>>
>>
>> To support BE, it may be more than Netcp driver. Do you recall, what
>> changes you did to get BE working on Keystone? Is it just NetCP driver?
>>
> IIRC it was Navigator (QMSS, DMA), NETCP, SPI and couple of
> of more drivers. Driver update was a massive patch done by Prabhu.
> 
Ok. Thanks.

Murali
> Regards,
> Santosh
> 
> 
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
