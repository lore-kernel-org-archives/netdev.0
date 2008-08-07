From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: qdisc_enqueue, NET_XMIT_SUCCESS and kfree_skb (Was: Re: [PATCH
	take 2] net_sched: Add qdisc __NET_XMIT_BYPASS flag)
Date: Thu, 07 Aug 2008 14:40:48 +0300
Message-ID: <20080807144048.10175sn7i3u7qlmo@hayate.ip6>
References: <20080731171431.GA9464@ami.dom.local>
	<4892AA16.40706@trash.net> <20080801101929.GA12735@ff.dom.local>
	<20080803.182524.240976246.davem@davemloft.net>
	<20080804062813.GA4570@ff.dom.local>
	<20080804213535.14214iqhxkx3v3so@hayate.ip6>
	<20080804210333.GA2849@ami.dom.local>
	<20080805154350.27523juch31xgjcw@hayate.ip6>
	<20080805155001.GA2526@ami.dom.local>
	<20080806224248.18266k9ahc5nkk8w@hayate.ip6>
	<20080806215258.GA3306@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=ISO-8859-1;
	DelSp="Yes";
	format="flowed"
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: "Jarek Poplawski" <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.dnainternet.fi ([87.94.96.108]:52908 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759258AbYHGMhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 08:37:14 -0400
In-Reply-To: <20080806215258.GA3306@ami.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Jarek Poplawski" <jarkao2@gmail.com>:

>> PS. I noticed something fishy in HTB; HTB always returns NET_XMIT_DROP if
>> qdisc_enqueue doesn't return full NET_XMIT_SUCCESS, shouldn't it  
>> return return
>> value from qdisc_enqueue. Same in HTB requeue. That can't be right, right?
>>
>
> Yes, very good point, and quite hard to diagnose bug - happily solved
> already (but not fixed yet) by David Miller himself.

Ok, I assume that same case in sch_prio:requeue has been already spotted too.

>
> PS: it seems your mailer wrapped some lines of above patch.
>

Doh, time to find alternative for horde.

  - Jussi

