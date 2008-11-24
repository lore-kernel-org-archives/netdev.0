From: jamal <j.hadi123@gmail.com>
Subject: Re: [PATCH] net: gen_estimator: Fix gen_kill_estimator() lookups
Date: Mon, 24 Nov 2008 10:00:58 -0500
Message-ID: <1227538858.22481.29.camel@dogo.mojatatu.com>
References: <20081124120404.GA16413@ff.dom.local>
	 <1227532725.22481.14.camel@dogo.mojatatu.com>
	 <20081124133724.GC16755@ff.dom.local>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Badalian Vyacheslav <slavon@bigtelecom.ru>,
	Denys Fedoryshchenko <denys@visp.net.lb>,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yx-out-2324.google.com ([74.125.44.29]:48891 "EHLO
	yx-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178AbYKXPBR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 10:01:17 -0500
Received: by yx-out-2324.google.com with SMTP id 8so836331yxm.1
        for <netdev@vger.kernel.org>; Mon, 24 Nov 2008 07:01:16 -0800 (PST)
In-Reply-To: <20081124133724.GC16755@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-11-24 at 13:37 +0000, Jarek Poplawski wrote:

> I first thought about a hash, but alas Patrick's solution is sched
> only... Anyway, I din't see too much overhead in memory use, and no
> diffrence in addition times (without batching).

Showing numbers in a commit for perf improvement IMO is always a good
thing.
BTW, I dont think it would make a noticeable difference (batching
notwithstanding) in addition or even deletion unless you have quiet a
few with the same estimate sampling time loaded.

cheers,
jamal

