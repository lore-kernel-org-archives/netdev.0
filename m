From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Glibc recvmsg from kernel netlink socket hangs forever
Date: Thu, 24 Sep 2015 22:34:10 -0700
Message-ID: <5604DCD2.4090600@roeck-us.net>
References: <C3C03EFC-53E1-45DE-87AF-59C7367BD21E@gmail.com>
 <20150925043653.GA29111@roeck-us.net>
 <20150925045853.GA5286@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Schlansker <stevenschlansker@gmail.com>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:56890 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850AbbIYFeY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 01:34:24 -0400
In-Reply-To: <20150925045853.GA5286@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert,

On 09/24/2015 09:58 PM, Herbert Xu wrote:
> On Thu, Sep 24, 2015 at 09:36:53PM -0700, Guenter Roeck wrote:
>>
>> http://comments.gmane.org/gmane.linux.network/363085
>>
>> might explain your problem.
>>
>> I thought this was resolved in 4.1, but it looks like the problem still persists
>> there. At least I have reports from my workplace that 4.1.6 and 4.1.7 are still
>> affected. I don't know if there have been any relevant changes in 4.2.
>>
>> Copying Herbert and Eric for additional input.
>
> There was a separate bug discovered by Tejun recently.  You need
> to apply the patches
>
> https://patchwork.ozlabs.org/patch/519245/
> https://patchwork.ozlabs.org/patch/520824/
>
I assume this is on top of mainline ?

> There is another follow-up but it shouldn't make any difference
> in practice.
>

Any idea what may be needed for 4.1 ?
I am currently trying https://patchwork.ozlabs.org/patch/473041/,
but I have no idea if that will help with the problem we are seeing there.

Thanks,
Guenter
