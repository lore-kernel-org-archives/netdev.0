From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Glibc recvmsg from kernel netlink socket hangs forever
Date: Fri, 25 Sep 2015 20:45:58 -0700
Message-ID: <560614F6.6050601@roeck-us.net>
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
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150925155511.GA9575@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert,

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

After applying your two patches, I don't see the problem in 4.1 anymore.
We'll run the system through regression; the complete cycle may take
a couple of weeks. I'll let you know if we find any further problems.

If you submit additional patches in that area, it would be great if you
can Cc: me.

Thanks,
Guenter
