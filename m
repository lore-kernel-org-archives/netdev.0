From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] sctp: use transport hashtable to replace
 association's with rhashtable
Date: Wed, 30 Dec 2015 12:52:04 -0500 (EST)
Message-ID: <20151230.125204.1385006803109278855.davem@davemloft.net>
References: <cover.1451490447.git.lucien.xin@gmail.com>
	<1451495979.8255.32.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: lucien.xin@gmail.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org, mleitner@redhat.com,
	vyasevic@redhat.com, daniel@iogearbox.net
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38439 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754866AbbL3RwH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2015 12:52:07 -0500
In-Reply-To: <1451495979.8255.32.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 30 Dec 2015 12:19:39 -0500

> Switching SCTP to rhashtable at this moment is premature, it is
> still moving fast.

I completely, and totally, disagree.

rhashtable actually _needs_ a strong active user like one of the
protocol socket hashes.

It's a step backwards to keep rhashtable in the shadows by only
allowing certain subsystems to convert to it.  That's really
incredibly stupid if you ask me.
