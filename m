From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH RFC] pkt_sched: Remove smp_wmb() in qdisc_watchdog()
Date: Fri, 19 Dec 2008 11:41:25 +0000
Message-ID: <20081219114125.GB17826@ff.dom.local>
References: <20081219113047.GA17826@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f17.google.com ([209.85.219.17]:57308 "EHLO
	mail-ew0-f17.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbYLSLla (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Dec 2008 06:41:30 -0500
Received: by ewy10 with SMTP id 10so1014472ewy.13
        for <netdev@vger.kernel.org>; Fri, 19 Dec 2008 03:41:29 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20081219113047.GA17826@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Dec 19, 2008 at 11:30:47AM +0000, Jarek Poplawski wrote:
...
> While implementing a TCQ_F_THROTTLED flag there was used an smp_wmb()
> in qdisc_watchdog(), but since this flag is practically used only in
> sch_netem(), and since it's not even clear what reordering is avoided

Hmm.. I forgot to mention sch_cbq(), but it doesn't use a barrier
anyway.

Jarek P.
