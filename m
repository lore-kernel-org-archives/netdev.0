From: Cong Wang <cwang@twopensource.com>
Subject: Re: [RGC PATCH v3.10] net: sched: validate that class is found in qdisc_tree_decrease_qlen
Date: Mon, 20 Jul 2015 11:47:59 -0700
Message-ID: <CAHA+R7MfAfhoTdNd217O=7Jww_3C4R4Yc5F0ZyCfU4q-eB4LHw@mail.gmail.com>
References: <1437175677-1252239-1-git-send-email-agartrell@fb.com>
	<CAHA+R7NgdD8xgi=RGcN7NjoL+p0M6vDxBPEwCjj3LZ9SWS5Yhw@mail.gmail.com>
	<CALCkm3fPck6QKRRqOUxwB18WMG8wAqGyRR+bMKPtu8mn2apbww@mail.gmail.com>
	<1437209428.1026.29.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alex Gartrell <alexgartrell@gmail.com>,
	Alex Gartrell <agartrell@fb.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	kernel-team <kernel-team@fb.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f174.google.com ([209.85.160.174]:34015 "EHLO
	mail-yk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756115AbbGTSsA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jul 2015 14:48:00 -0400
Received: by ykax123 with SMTP id x123so146525183yka.1
        for <netdev@vger.kernel.org>; Mon, 20 Jul 2015 11:47:59 -0700 (PDT)
In-Reply-To: <1437209428.1026.29.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 18, 2015 at 1:50 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
> HTB + fq_codel ?
>
> Make sure you applied Cong fix
>

I think only cbq actually uses ->drop(), the rest simply call ->drop()
for the lower
qdisc's. No?
