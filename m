From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 00/14]: Killing qdisc->ops->requeue().
Date: Tue, 14 Oct 2008 19:56:49 +0200
Message-ID: <20081014175649.GA2548@ami.dom.local>
References: <48F4915D.8000004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:11699 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750812AbYJNR4Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 13:56:16 -0400
Received: by ug-out-1314.google.com with SMTP id k3so1004361ugf.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 10:56:13 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <48F4915D.8000004@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,
I acknowledge Patrick's concerns, so please, consider this
patch-set as withdrawn. Thanks.

A little comment below:

Patrick McHardy wrote, On 10/14/2008 02:32 PM:
> Jarek Poplawski wrote:
...
> I'm sorry for any wasted effort, I think I mentioned this one or
> two month ago, but wasn't able to further participate in the
> discussion because I was busy with other things.

No problem, it seems I missed your point.

>> Alas, I can't analyze your concerns at the moment, and I'll try to
>> reply in the evening yet, but my idea was this all shouldn't make
>> (almost) any visible change just for HFSC, so if it's otherwise,
>> something went wrong. IMHO, with this solution hfsc_requeue() way is
>> simply realized as a standard now, but I can miss something.
> 
> The main difference results from the fact that higher priority
> packets can't preempt "peeked" lower priority packets anymore.
> The difference this causes obviously depends on the bandwidth,
> but in my opinion the impact (as mentioned. 12ms delay for
> 1500b, 1mbit, rises linearly with bigger packets/less bandwidth)
> is large enough to speak against these changes.

Actually, I think I had similar doubts one or two months ago, but I
can remember mainly your discussion on peek with Herbert, and not
much about something like above, but probably I didn't pay enough
attention.

Anyway, the main source of my misleading seems to be HFSC... So do you
mean it's OK to use this kind of requeuing in hfsc_requeue(), but not
elsewhere? Maybe I miss something, but if some other qdisc is used as
a parent of HFSC, and does something like qdisc_peek_len(), it gets
just what you're against above?

Anyway, I'm glad you've found some time for these explanations,
especially since they're in accordance with my previous suspicions.

Thanks again,
Jarek P.
