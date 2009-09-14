From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] pkt_sched: Fix qdisc_graft WRT ingress qdisc
Date: Mon, 14 Sep 2009 19:58:26 +0200
Message-ID: <4AAE8442.4030604@trash.net>
References: <20090914083544.GA10444@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:59367 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755849AbZINR6Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Sep 2009 13:58:24 -0400
In-Reply-To: <20090914083544.GA10444@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski wrote:
> After the recent mq change using ingress qdisc overwrites dev->qdisc;
> there is also a wrong old qdisc pointer passed to notify_and_destroy.

Good catch, thanks.
