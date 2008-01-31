From: Andi Kleen <ak@suse.de>
Subject: Re: hard hang through qdisc
Date: Thu, 31 Jan 2008 19:55:16 +0100
Message-ID: <20080131185516.GI25989@bingen.suse.de>
References: <200801311321.01015.ak@suse.de> <47A1CD4E.7050701@trash.net> <47A1D4F2.6080904@trash.net> <200801311604.28110.ak@suse.de> <47A1E556.3050900@trash.net> <47A2176A.7080606@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@suse.de>, hadi@cyberus.ca, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.suse.de ([195.135.220.2]:38126 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757021AbYAaSzU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Jan 2008 13:55:20 -0500
Content-Disposition: inline
In-Reply-To: <47A2176A.7080606@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 31, 2008 at 07:46:02PM +0100, Patrick McHardy wrote:
> Patrick McHardy wrote:
>> Andi Kleen wrote:
>>
>>> Can you please try with the above config?
>> I'll give it a try later.
>
>
> I took all options from that config that seemed possibly
> related (qdiscs, no hrtimers, no nohz, slab, ...), but
> still can't reproduce it.

Ok I'll do bisect then later (not today anymore likely) 

> Does it also crash if you use more reasonable parameters?

I managed to make it crash with different parameters too,
but with good parameters it did set a qdisc successfully
and appeared to work.

-Andi
