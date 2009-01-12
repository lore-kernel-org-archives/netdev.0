From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 7/6] Re: [PATCH 2/6] pkt_sched: sch_htb: Consider used
	jiffies in htb_dequeue()
Date: Mon, 12 Jan 2009 10:10:47 +0000
Message-ID: <20090112101047.GA5448@ff.dom.local>
References: <20081210093532.GA7926@ff.dom.local> <20081216.155722.144236025.davem@davemloft.net> <20081217070303.GA4577@ff.dom.local> <20081216.233801.26557633.davem@davemloft.net> <496AE9A5.9060507@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, devik@cdi.cz,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:43172 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752327AbZALKKy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 05:10:54 -0500
Received: by ewy10 with SMTP id 10so11407927ewy.13
        for <netdev@vger.kernel.org>; Mon, 12 Jan 2009 02:10:52 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <496AE9A5.9060507@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 12, 2009 at 07:56:37AM +0100, Patrick McHardy wrote:
> David Miller wrote:
>> From: Jarek Poplawski <jarkao2@gmail.com>
>> Date: Wed, 17 Dec 2008 07:03:03 +0000
>>
>>> On Tue, Dec 16, 2008 at 03:57:22PM -0800, David Miller wrote:
>>>> Patrick, I know you said you were travelling and very busy,
>>>> but Jarek has been waiting patiently for you to review
>>>> these two newly respun patches.
>>>>
>>>> These are just rotting in my patch queue and I'd like to
>>>> do something with them.
>>> I guess Patrick has some doubts, but since these patches are not
>>> critical, let's say I'll resend them within a few weeks.
>>
>> Fair enough, I'll mark them deferred on patchwork
>
> Sorry, I dropped the ball on this one. I still think scheduling
> a work-queue or something else running in process context to
> kick the queue once the scheduler had a chance to run would
> be a better solution. But Jarek's patches are an improvement
> to the current situation, so no objections from me.
>

Thanks for the review Patrick. As I wrote before, I'm not against
using a workqueue here: it's logically better, but I still think
this place is rather exception, so I'm not convinced we should
care so much adding better solution, but also some overhead when
cancelling this workqueue. But if it really bothers you, please
confirm, and I'll do it. BTW, I wonder if adding the old "too many
events" warning back wouldn't be more useful here.

David, I'm not sure you can still track these patches, so I'll
soon resend them (2 patches: #7/6 and 8/6).

Thanks,
Jarek P.
