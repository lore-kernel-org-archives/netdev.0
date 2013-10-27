From: David Miller <davem@davemloft.net>
Subject: Re: 16% regression on 10G caused by TCP small queues
Date: Sun, 27 Oct 2013 01:07:33 -0400 (EDT)
Message-ID: <20131027.010733.172184644367096185.davem@davemloft.net>
References: <20131023214557.386aad1a@nehalam.linuxnetplumber.net>
	<20131024.030121.477884925478012615.davem@davemloft.net>
	<20131027043351.GA27876@lists.bufferbloat.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, ncardwell@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org
To: dave.taht@bufferbloat.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47828 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750938Ab3J0FHh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 01:07:37 -0400
In-Reply-To: <20131027043351.GA27876@lists.bufferbloat.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Taht <dave.taht@bufferbloat.net>
Date: Sat, 26 Oct 2013 21:33:52 -0700

> On Thu, Oct 24, 2013 at 03:01:21AM -0400, David Miller wrote:
>> From: Stephen Hemminger <stephen@networkplumber.org>
>> Date: Wed, 23 Oct 2013 21:45:57 -0700
>> 
>> > Sorry, thought sk_pacing_rate depended on FQ qdisc but it is other way around.
>> > In which case doing merge of these two was sufficient to fix the problem.
>> > With a minor manual fix up to tcp.h.
>> 
>> I know, I already have a half-built tree of -stable submissions
>> that does exactlty this.
> 
> I know that the "fq" qdisc is not exactly a -stable thing, but if it's simpler
> to include it rather than sort through the patch sets, I'm all for it.

I'm not including 'fq' and it's absolutely not necessary to fix this
bug.

'fq' is only incidentary to this bug fix because it just so happens to
make use of sk->sk_pacing_rate.  There is no other connection between
these two things.
