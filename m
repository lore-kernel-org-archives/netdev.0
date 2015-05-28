From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 08:51:22 -0700
Message-ID: <1432828282.7456.17.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
	 <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
	 <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>,
	John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:36108 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932326AbbE1PvY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 11:51:24 -0400
Received: by igbpi8 with SMTP id pi8so115439109igb.1
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 08:51:23 -0700 (PDT)
In-Reply-To: <746223891.124020.1432827038389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 11:30 -0400, jsullivan@opensourcedevel.com wrote:

> Interesting but this is destined to become a critical production system for a
> high profile, internationally recognized product so I am hesitant to patch.  I
> doubt I can convince my company to do it but is improving IFB the sort of
> development effort that could be sponsored and then executed in a moderately
> short period of time? Thanks - John

I intend to submit this patch very officially.

Note that some Google servers use the same feature with good success on
other NIC. This allowed us to remove interrupt coalescing, lowering RPC
latencies, but keeping good throughput and cpu efficiency for bulk
flows.

http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/commit/?id=1a2881728211f0915c0fa1364770b9c73a67a073

While IFB might need quite a lot of efforts, I don't know.

You certainly can ask to John Fastabend if he has plans about it in the
short term.
