From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFT 2/4] Add mod_timer_noact
Date: Wed, 18 Feb 2009 13:33:24 +0100
Message-ID: <499C0014.6090308@trash.net>
References: <20090218051906.174295181@vyatta.com> <20090218052747.437271195@vyatta.com> <20090218092041.GC3294@elte.hu> <20090218.013007.117003889.davem@davemloft.net> <20090218110144.GA4100@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	rick.jones2@hp.com, dada1@cosmosbay.com, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, tglx@linutronix.de,
	gandalf@wlug.westbo.se, linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:51319 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754000AbZBRMd0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Feb 2009 07:33:26 -0500
In-Reply-To: <20090218110144.GA4100@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ingo Molnar wrote:
> In other words, the changelog is useless and even borderline 
> deceptive. Not a good sign if you are trying to get a patch 
> accepted to the kernel.
> 
> Furthermore, no performance figures were posted along with this 
> modification - it only stated that these are "performance 
> improvements". Especially in cases where a change slows down the 
> common case the showing of a very substantial performance 
> benefit is a must-have, before a patch is considered for 
> upstream merging.

I think this is mainly a misunderstanding, Stephen posted these
patches as RFT so Rick and Eric could do benchmarks, they were
not intended for merging at this time.

> In fact, the submission incorrectly stated:
> 
> | This patch set is against Patrick's netfilter next tree since
> | it is where it should end up.
> |      
> | git.kernel.org:/pub/scm/linux/kernel/git/kaber/nf-next-2.6.git
> 
> This is wrong, the "netfilter next tree" is not where the "Add 
> mod_timer_noact" change should end up, and you should ask your 
> contributors to submit changes to other subsystems to their 
> respective maintainer trees - the timer tree in this case.

Absolutely, I wouldn't have taken it, and Dave wouldn't have taken
it from me, so no cause for alarm :)


