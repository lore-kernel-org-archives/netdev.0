From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Glibc recvmsg from kernel netlink socket hangs forever
Date: Fri, 25 Sep 2015 09:14:31 -0700
Message-ID: <560572E7.6010503@roeck-us.net>
References: <C3C03EFC-53E1-45DE-87AF-59C7367BD21E@gmail.com>
 <20150925043653.GA29111@roeck-us.net>
 <20150925045853.GA5286@gondor.apana.org.au> <5604DCD2.4090600@roeck-us.net>
 <20150925155511.GA9575@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Schlansker <stevenschlansker@gmail.com>,
	linux-kernel@vger.kernel.org, Eric Dumazet <edumazet@google.com>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:48663 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752898AbbIYQOf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Sep 2015 12:14:35 -0400
In-Reply-To: <20150925155511.GA9575@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/25/2015 08:55 AM, Herbert Xu wrote:
> On Thu, Sep 24, 2015 at 10:34:10PM -0700, Guenter Roeck wrote:
>>
>> Any idea what may be needed for 4.1 ?
>> I am currently trying https://patchwork.ozlabs.org/patch/473041/,
>
> This patch should not make any difference on 4.1 and later because
> 4.1 is where I rewrote rhashtable resizing and it should work (or
> if it is broken then the latest kernel should be broken too).
>
Yes, applying (only) the above patch to 4.1 didn't help.

>> but I have no idea if that will help with the problem we are seeing there.
>
> Having looked at your message agin I don't think the issue I
> alluded to is relevant since the symptom there ought to be a
> straight kernel lock-up as opposed to just a user-space one because
> you will end up with the kernel sending a message to itself.
>
> And the fact that 4.2 works is more indicative as the bug is
> present in both 4.1 and 4.2.
>
> I'll try to reproduce this in 4.1 as time permits but no promises.
>

I applied your patches (and a few additional netlink changes from 4.2)
to our 4.1 branch. I'll let you know if it makes a difference for us.

Thanks,
Guenter
