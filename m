From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] route: fix ICMP secure_redirects
Date: Mon, 07 Nov 2011 13:35:41 -0500 (EST)
Message-ID: <20111107.133541.808346933690781560.davem@davemloft.net>
References: <1320680505-26367-1-git-send-email-fbl@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fbl@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35552 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab1KGSfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2011 13:35:44 -0500
In-Reply-To: <1320680505-26367-1-git-send-email-fbl@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Flavio Leitner <fbl@redhat.com>
Date: Mon,  7 Nov 2011 13:41:45 -0200

> It should accept ICMP redirects from any host and not
> just from gateways when secure_redirects is disabled.
> 
> Signed-off-by: Flavio Leitner <fbl@redhat.com>

This is changing the default behavior, and could break things for people.

We have sort-of discussed this already, and agreed that the tests made in
this code before my inetpeer reworking had to be reinstated exactly as it
was.
