From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net v2] ipv6: sr: fix user space compilation error with
 old glibc
Date: Tue, 23 May 2017 19:27:07 +0200
Message-ID: <592470EB.5090701@iogearbox.net>
References: <20170515110320.23369-1-david.lebrun@uclouvain.be> <20170515.100922.2194549018034831667.davem@davemloft.net> <9f06720b-1a6e-2a0b-0756-70e9e73b631f@uclouvain.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Lebrun <david.lebrun@uclouvain.be>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:55597 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S965708AbdEWR1L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 13:27:11 -0400
In-Reply-To: <9f06720b-1a6e-2a0b-0756-70e9e73b631f@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/15/2017 04:21 PM, David Lebrun wrote:
> On 05/15/2017 04:09 PM, David Miller wrote:
>> Please, no.
>>
>> The reason we put together a method by which glibc and the kernel can
>> stay out of eachother's way in header files is exactly so that we
>> don't need ifdefs that conditionally do netinet/in.h vs. using the
>> kernel header.
>>
>> There are more than a dozen other UAPI headers which make use of
>> linux/in6.h and none of them jump through hoops like what is being
>> proposed here, and that's on purpose.
>>
>> So special casing this one one header is really not the way to go.
>
> Mmmh it's true that special casing in kernel headers for a user space
> issue is not the best way to go.. I'll find a way to solve this in user
> space only.
>
> Sorry about the lousy patch.

Any new outcomes so far?

Thanks,
Daniel
