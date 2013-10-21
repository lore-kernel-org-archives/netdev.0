From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] netpoll: linearize skb before accessing its data
Date: Mon, 21 Oct 2013 18:33:51 -0400 (EDT)
Message-ID: <20131021.183351.1700002768190145909.davem@davemloft.net>
References: <1382391080-1607-1-git-send-email-antonio@meshcoding.com>
	<1382394336.3284.92.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: antonio@meshcoding.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44183 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751788Ab3JUWdx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Oct 2013 18:33:53 -0400
In-Reply-To: <1382394336.3284.92.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 21 Oct 2013 15:25:36 -0700

> Anyway, how I see nothing sets rx_hook, what am I missing ?

Only out of tree code makes use of this facility, and it's been
this way since the facility was introduced.

Yes, I'm disappointed and unhappy about this too.
