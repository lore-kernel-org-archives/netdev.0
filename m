From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb (Was: Re: [PATCH
	take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag)
Date: Thu, 7 Aug 2008 12:23:03 +0000
Message-ID: <20080807122303.GB13299@ff.dom.local>
References: <20080801101929.GA12735@ff.dom.local> <20080803.182524.240976246.davem@davemloft.net> <20080804062813.GA4570@ff.dom.local> <20080804213535.14214iqhxkx3v3so@hayate.ip6> <20080804210333.GA2849@ami.dom.local> <20080805154350.27523juch31xgjcw@hayate.ip6> <20080805155001.GA2526@ami.dom.local> <20080806224248.18266k9ahc5nkk8w@hayate.ip6> <20080806215258.GA3306@ami.dom.local> <20080807144048.10175sn7i3u7qlmo@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ik-out-1112.google.com ([66.249.90.182]:44971 "EHLO
	ik-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754607AbYHGMXs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:23:48 -0400
Received: by ik-out-1112.google.com with SMTP id c28so417194ika.5
        for <netdev@vger.kernel.org>; Thu, 07 Aug 2008 05:23:46 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080807144048.10175sn7i3u7qlmo@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 07, 2008 at 02:40:48PM +0300, Jussi Kivilinna wrote:
> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
>
>>> PS. I noticed something fishy in HTB; HTB always returns NET_XMIT_DROP if
>>> qdisc_enqueue doesn't return full NET_XMIT_SUCCESS, shouldn't it  
>>> return return
>>> value from qdisc_enqueue. Same in HTB requeue. That can't be right, right?
>>>
>>
>> Yes, very good point, and quite hard to diagnose bug - happily solved
>> already (but not fixed yet) by David Miller himself.
>
> Ok, I assume that same case in sch_prio:requeue has been already spotted too.
>

Actually, I didn't hear about this!? After the HTB case David waits
for Patrick's audit, and this seems to get some time.

So, looks like another good point, and IMHO, you should send a patch
for for this.

Jarek P.
