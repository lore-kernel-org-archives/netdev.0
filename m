From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] pkt_sched: gen_estimator: Dont report fake rate
 estimators
Date: Thu, 01 Oct 2009 14:14:06 -0700 (PDT)
Message-ID: <20091001.141406.62574384.davem@davemloft.net>
References: <4AC4FE07.5070204@gmail.com>
	<20091001.123725.02194664.davem@davemloft.net>
	<4AC519B1.1090701@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, kaber@trash.net, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39871
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752106AbZJAVNr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:13:47 -0400
In-Reply-To: <4AC519B1.1090701@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 01 Oct 2009 23:05:53 +0200

> Since you ask... I wonder about this whole int plus quite a bit of
> struct unreadability for one flag only. Maybe it could be queried
> on qdisc level (with a flag if necessary), and additional parameter
> of gnet_stats_copy_rate_est()? (Qdiscs should have no problem with
> setting this param for their classes too.)

Certainly, that's another approach to this problem.

But logically, just like we wouldn't emit a block of RED scheduler
data to 'tc' unless RED is actually configured, it seems consistent to
not emit estimator data when no estimator is even there.
