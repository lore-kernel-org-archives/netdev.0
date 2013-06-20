From: Chris Boot <bootc@bootc.net>
Subject: Re: PANIC at net/xfrm/xfrm_output.c:125 (3.9.4)
Date: Thu, 20 Jun 2013 21:36:44 +0100
Message-ID: <51C367DC.8050808@bootc.net>
References: <51AFB204.8070009@bootc.net> <20130606010416.GF26681@mail.gmail.com> <51AFE4C2.1000604@windriver.com> <51B03EAC.6080508@bootc.net> <20130606113840.511a72c3@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Fan Du <fan.du@windriver.com>, Jean Sacren <sakiwit@gmail.com>,
	steffen.klassert@secunet.com, herbert@gondor.hengli.com.au,
	davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Timo Teras <timo.teras@iki.fi>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130606113840.511a72c3@vostro>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/06/2013 09:38, Timo Teras wrote:
> On Thu, 06 Jun 2013 08:47:56 +0100
> Chris Boot <bootc@bootc.net> wrote:
> 
>> On 06/06/13 02:24, Fan Du wrote:
>>> Hello Chris/Jean
>>>
>>> This issue might have already been fixed by this:
>>> https://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/net/xfrm/xfrm_output.c?id=497574c72c9922cf20c12aed15313c389f722fa0
>>>
>>>
>>> Hope it helps.
>>
>> Hi Fan, Jean,
>>
>> Thanks, that looks like it's the patch for exactly my problem.
>> Unfortunately I can't test it until next week now. :-/
>>
>> Timo/Dave: are there any plans to push this into 3.10-rc and/or
>> stable? I seem to be able to hit the issue pretty reliably.
> 
> It is already present in 3.10-rc3 [1], and Dave has it queued for
> 3.9-stable [2].
> 
> - Timo
> 
> [1] http://lwn.net/Articles/551922/
> [2] http://patchwork.ozlabs.org/patch/245594/

Hi folks,

I'm just wondering if this patch has got lost in the cracks; I reported
the issue in 3.9.4 and 3.9.7 is just out without any sign of it. Have I
missed something?

Thanks,
Chris

-- 
Chris Boot
bootc@bootc.net
