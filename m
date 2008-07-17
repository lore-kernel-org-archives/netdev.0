From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH] sctp: remove unnecessary byteshifting, calculate crc
 in	big-endian
Date: Thu, 17 Jul 2008 15:24:31 -0400
Message-ID: <487F9C6F.3080802@hp.com>
References: <1215133995.16647.51.camel@brick>  <487526B8.70903@hp.com>	 <1215651704.476.92.camel@brick>  <487603F0.9070604@hp.com> <1216322461.6029.3.camel@brick>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>
To: Harvey Harrison <harvey.harrison@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:20186 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932815AbYGQT0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2008 15:26:00 -0400
In-Reply-To: <1216322461.6029.3.camel@brick>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Harvey Harrison wrote:
> On Thu, 2008-07-10 at 08:43 -0400, Vlad Yasevich wrote:
>> Harvey Harrison wrote:
>>> On Wed, 2008-07-09 at 16:59 -0400, Vlad Yasevich wrote:
>>>> Harvey Harrison wrote:
>>>>> -	__u32 crc32 = 0;
>>>>> +	__be32 crc32 = cpu_to_be32(0);
>>>> Does this actually do anything?
>>>>
>>>> Otherwise, good clean-up. Thanks
>>>>
>>> Keeps sparse happy.
>> Wouldn't just a (__force __be32)0 do the same thing and
>> avoid useless byte swapping on little endian?
>>
> 
> Vlad, do you want me to revise the patch, or were you taking it as is?
> 
> Harvey
> 


Could you fix it please.

Thanks
-vlad
