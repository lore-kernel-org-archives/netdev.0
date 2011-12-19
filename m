From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/sched: sch_plug - Queue traffic until an explicit
 release command
Date: Mon, 19 Dec 2011 16:35:17 -0500 (EST)
Message-ID: <20111219.163517.142436937064950002.davem@davemloft.net>
References: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, netdev@vger.kernel.org, brendan@cs.ubc.ca
To: rshriram@cs.ubc.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:59311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751974Ab1LSVfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2011 16:35:24 -0500
In-Reply-To: <1324329752-28459-1-git-send-email-rshriram@cs.ubc.ca>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: rshriram@cs.ubc.ca
Date: Mon, 19 Dec 2011 13:22:32 -0800

> +#define FIFO_BUF    (10*1024*1024)

This limit is, at best, extremely arbitrary.
