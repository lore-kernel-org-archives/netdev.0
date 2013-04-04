From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] tcp: add a global sysctl to control TCP
 delayed ack
Date: Thu, 04 Apr 2013 19:25:39 -0400 (EDT)
Message-ID: <20130404.192539.1157364077083658871.davem@davemloft.net>
References: <1365070560-11544-1-git-send-email-amwang@redhat.com>
	<20130404224810.GE23056@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org, eric.dumazet@gmail.com,
	rick.jones2@hp.com, shemminger@vyatta.com, tgraf@suug.ch,
	David.Laight@ACULAB.COM
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51537 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765271Ab3DDXZo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 19:25:44 -0400
In-Reply-To: <20130404224810.GE23056@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 5 Apr 2013 00:48:10 +0200

> I totally understand the objections that were given regarding this
> patch. But for defense of this patch we also provide a knob to disable
> slow start after idle, which from my point of view is as "evil" as
> this change.

I completely disagree, slow start after idle is way too aggressively
throwing past history away, so turning that off is much safer.
