From: David Miller <davem@davemloft.net>
Subject: Re: PANIC at net/xfrm/xfrm_output.c:125 (3.9.4)
Date: Wed, 26 Jun 2013 15:17:36 -0700 (PDT)
Message-ID: <20130626.151736.1797290996825764087.davem@davemloft.net>
References: <51B03EAC.6080508@bootc.net>
	<20130606113840.511a72c3@vostro>
	<51C367DC.8050808@bootc.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timo.teras@iki.fi, fan.du@windriver.com, sakiwit@gmail.com,
	steffen.klassert@secunet.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: bootc@bootc.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51C367DC.8050808@bootc.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Boot <bootc@bootc.net>
Date: Thu, 20 Jun 2013 21:36:44 +0100

> On 06/06/2013 09:38, Timo Teras wrote:
>> On Thu, 06 Jun 2013 08:47:56 +0100
>> Chris Boot <bootc@bootc.net> wrote:
>> 
>>> On 06/06/13 02:24, Fan Du wrote:
>>>> Hello Chris/Jean
>>>>
>>>> This issue might have already been fixed by this:
>>>> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/net/xfrm/xfrm_output.c?id=497574c72c9922cf20c12aed15313c389f722fa0
>>>>
>>>>
>>>> Hope it helps.
>>>
>>> Hi Fan, Jean,
>>>
>>> Thanks, that looks like it's the patch for exactly my problem.
>>> Unfortunately I can't test it until next week now. :-/
>>>
>>> Timo/Dave: are there any plans to push this into 3.10-rc and/or
>>> stable? I seem to be able to hit the issue pretty reliably.
>> 
>> It is already present in 3.10-rc3 [1], and Dave has it queued for
>> 3.9-stable [2].
>> 
>> - Timo
>> 
>> [1] http://lwn.net/Articles/551922/
>> [2] http://patchwork.ozlabs.org/patch/245594/
> 
> I'm just wondering if this patch has got lost in the cracks; I reported
> the issue in 3.9.4 and 3.9.7 is just out without any sign of it. Have I
> missed something?

It got submitted to -stable last week.
