From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] netfilter: unregister nf hooks, matches and targets in
 the reverse order
Date: Sat, 2 Oct 2010 01:57:16 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1010020157010.26371@obet.zrqbmnf.qr>
References: <1283436908-10744-1-git-send-email-xiaosuo@gmail.com> <4C91033B.6070902@trash.net> <AANLkTi=AhK0jDM8WEf5tHhervKUpB6f4MR+mNx2moYuC@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:56681 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752363Ab0JAX5S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Oct 2010 19:57:18 -0400
In-Reply-To: <AANLkTi=AhK0jDM8WEf5tHhervKUpB6f4MR+mNx2moYuC@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 2010-09-19 07:58, Changli Gao wrote:

>On Thu, Sep 16, 2010 at 1:32 AM, Patrick McHardy <kaber@trash.net> wrote:
>> Am 02.09.2010 16:15, schrieb Changli Gao:
>>> Since we register nf hooks, matches and targets in order, we'd better
>>> unregister them in the reverse order.
>>
>> Why? Is there a specific bug you've noticed?
>>
>
>No, there isn't any bug. I just think unregistering them in the
>reverse order is more resonable, like the rollback when failing. And
>the code patched generates less object:

I support this.
