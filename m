From: "Jussi Kivilinna" <jussi.kivilinna@mbnet.fi>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Fri, 25 Jul 2008 15:29:32 +0300
Message-ID: <20080725152932.93641c4o5qk1sx0g@hayate.ip6>
References: <20080719233506.12596.59935.stgit@fate.lan>
	<20080725105748.GB10399@ff.dom.local>
	<20080725.035712.33516738.davem@davemloft.net>
	<20080725113757.GC10399@ff.dom.local>
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
Received: from smtp1.dnainternet.fi ([87.94.96.108]:55785 "EHLO
	smtp1.dnainternet.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754760AbYGYM3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 08:29:35 -0400
In-Reply-To: <20080725113757.GC10399@ff.dom.local>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Quoting "Jarek Poplawski" <jarkao2@gmail.com>:

> OK, I see htb did this earlier with ".packets", so it looks like I'm
> wrong with this - sorry! (Anyway, it seems to unnecessarily restrict
> the way qdisc are working.)
>

Would it be better for qdisc_enqueue() to pass packet length to caller?

  - Jussi


