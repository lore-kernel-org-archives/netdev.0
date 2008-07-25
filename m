From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH v2 2/3] net_sched: Add accessor function for packet
	length for qdiscs
Date: Fri, 25 Jul 2008 12:54:15 +0000
Message-ID: <20080725125414.GB25369@ff.dom.local>
References: <20080719233506.12596.59935.stgit@fate.lan> <20080725105748.GB10399@ff.dom.local> <20080725.035712.33516738.davem@davemloft.net> <20080725113757.GC10399@ff.dom.local> <20080725152932.93641c4o5qk1sx0g@hayate.ip6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	netdev@vger.kernel.org
To: Jussi Kivilinna <jussi.kivilinna@mbnet.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.168]:1971 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752726AbYGYMtH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 08:49:07 -0400
Received: by ug-out-1314.google.com with SMTP id h2so1103ugf.16
        for <netdev@vger.kernel.org>; Fri, 25 Jul 2008 05:49:05 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20080725152932.93641c4o5qk1sx0g@hayate.ip6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 25, 2008 at 03:29:32PM +0300, Jussi Kivilinna wrote:
> Quoting "Jarek Poplawski" <jarkao2@gmail.com>:
>
>> OK, I see htb did this earlier with ".packets", so it looks like I'm
>> wrong with this - sorry! (Anyway, it seems to unnecessarily restrict
>> the way qdisc are working.)
>>
>
> Would it be better for qdisc_enqueue() to pass packet length to caller?
>

Is it's really needed? Actually, if it's only for stats, I really
can't see the reason why not to get this info old way - before
enqueing? (And this could be not enough if we want packets count
like in htb.)

Jarek P.
