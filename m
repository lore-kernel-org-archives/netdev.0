From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] tcp: metrics: Delete all entries matching a
 certain destination
Date: Tue, 17 Dec 2013 14:57:51 -0500 (EST)
Message-ID: <20131217.145751.53681780657108721.davem@davemloft.net>
References: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
	<1387109444-1104-4-git-send-email-christoph.paasch@uclouvain.be>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, ja@ssi.bg
To: christoph.paasch@uclouvain.be
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48541 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751976Ab3LQT5w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 14:57:52 -0500
In-Reply-To: <1387109444-1104-4-git-send-email-christoph.paasch@uclouvain.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christoph Paasch <christoph.paasch@uclouvain.be>
Date: Sun, 15 Dec 2013 13:10:43 +0100

> As we now can have multiple entries per destination-IP, the "ip
> tcp_metrics delete address ADDRESS" command should delete all of them.
> 
> Signed-off-by: Christoph Paasch <christoph.paasch@uclouvain.be>

You have to adjust how you're doing patches #3 and #4.

Create the new attribute for the source address first, then
allow the source address to be specified in the deletion
command.

Make the source address optional in delete commands, to be
compatible with existing tools, and have it mean "ANY".
