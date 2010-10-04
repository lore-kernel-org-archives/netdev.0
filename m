From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: unregister nf hooks, matches and targets in
 the reverse order
Date: Mon, 04 Oct 2010 22:26:33 +0200
Message-ID: <4CAA3879.1020406@trash.net>
References: <1283436908-10744-1-git-send-email-xiaosuo@gmail.com> <4C91033B.6070902@trash.net> <AANLkTi=AhK0jDM8WEf5tHhervKUpB6f4MR+mNx2moYuC@mail.gmail.com> <alpine.LNX.2.01.1010020157010.26371@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LNX.2.01.1010020157010.26371@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Am 02.10.2010 01:57, schrieb Jan Engelhardt:
> On Sunday 2010-09-19 07:58, Changli Gao wrote:
> 
>> On Thu, Sep 16, 2010 at 1:32 AM, Patrick McHardy <kaber@trash.net> wrote:
>>> Am 02.09.2010 16:15, schrieb Changli Gao:
>>>> Since we register nf hooks, matches and targets in order, we'd better
>>>> unregister them in the reverse order.
>>>
>>> Why? Is there a specific bug you've noticed?
>>>
>>
>> No, there isn't any bug. I just think unregistering them in the
>> reverse order is more resonable, like the rollback when failing. And
>> the code patched generates less object:
> 
> I support this.

Yeah, it seems reasonable, although I don't like changing things
without a concrete reason. Anyways, applied, thanks everyone.
