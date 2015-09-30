From: Mathias Krause <minipli@googlemail.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Wed, 30 Sep 2015 15:38:31 +0200
Message-ID: <CA+rthh_ueokQKoVoHFpX_76Np+E3kOVc-x5g5-B059eujnq30A@mail.gmail.com>
References: <20150913195354.GA12352@jig.fritz.box>
	<20150914023949.GA15012@dcvr.yhbt.net>
	<CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
	<560AE202.4020402@akamai.com>
	<CA+rthh9XU+5oN9Ua-+8XPF9Q0y03FZyxds53sxUjsvsJN2kaJA@mail.gmail.com>
	<87612skwfb.fsf@doppelsaurus.mobileactivedefense.com>
	<CA+rthh_LqYaOBBMmdCa=zo55ukVDTff-pKM8cw0HzJDapg5Vvg@mail.gmail.com>
	<87pp10t4wp.fsf@doppelsaurus.mobileactivedefense.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Jason Baron <jbaron@akamai.com>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"peterz@infradead.org" <peterz@infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <87pp10t4wp.fsf@doppelsaurus.mobileactivedefense.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 30 September 2015 at 15:25, Rainer Weikusat
<rweikusat@mobileactivedefense.com> wrote:
> Mathias Krause <minipli@googlemail.com> writes:
>> On 30 September 2015 at 12:56, Rainer Weikusat <rweikusat@mobileactivedefense.com> wrote:
>>> In case you want some information on this: This is a kernel warning I
>>> could trigger (more than once) on the single day I could so far spend
>>> looking into this (3.2.54 kernel):
>>>
>>> Sep 15 19:37:19 doppelsaurus kernel: WARNING: at lib/list_debug.c:53 list_del+0x9/0x30()
>>> Sep 15 19:37:19 doppelsaurus kernel: Hardware name: 500-330nam
>>> Sep 15 19:37:19 doppelsaurus kernel: list_del corruption. prev->next should be ffff88022c38f078, but was dead000000100100
>>> [snip]
>>
>> Is that with Jason's patch or a vanilla v3.2.54?
>
> That's a kernel warning which occurred repeatedly (among other "link
> pointer disorganization" warnings) when I tested the "program with
> unknown behaviour" you wrote with the kernel I'm currently supporting a
> while ago (as I already wrote in the original mail).

So I assume Jason's patch is not included in your kernel. Then those
messages are expected; expected even on kernels as old as v2.6.27.
Can you re-try with Jason's patch applied?

Thanks,
Mathias
