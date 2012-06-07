From: David Miller <davem@davemloft.net>
Subject: Re: tcp wifi upload performance and lots of ACKs
Date: Thu, 07 Jun 2012 11:10:13 -0700 (PDT)
Message-ID: <20120607.111013.2155552765767462604.davem@davemloft.net>
References: <AE90C24D6B3A694183C094C60CF0A2F6026B6F3C@saturn3.aculab.com>
	<4FD0EA18.3090606@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, greearb@candelatech.com,
	dbaluta@ixiacom.com, netdev@vger.kernel.org
To: rick.jones2@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44779 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760930Ab2FGSKO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 14:10:14 -0400
In-Reply-To: <4FD0EA18.3090606@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rick Jones <rick.jones2@hp.com>
Date: Thu, 07 Jun 2012 10:51:20 -0700

> This may not work well when the sender has a congestion window growth
> heuristic different from what the ACK avoidance heuristic assumes.  If
> I recall correctly, the heuristic in HP-UX assumes the sender grows
> cwnd by the number of bytes/segments ACKnowledged.

Linux violates this assumption.
