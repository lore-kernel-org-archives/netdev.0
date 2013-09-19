From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2 1/2] ip: use ip_hdr() in __ip_make_skb() to
 retrieve IP header
Date: Thu, 19 Sep 2013 14:11:30 -0400 (EDT)
Message-ID: <20130919.141130.1213345571099136917.davem@davemloft.net>
References: <1379543393-7446-1-git-send-email-aatteka@nicira.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: aatteka@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752417Ab3ISSLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Sep 2013 14:11:32 -0400
In-Reply-To: <1379543393-7446-1-git-send-email-aatteka@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ansis Atteka <aatteka@nicira.com>
Date: Wed, 18 Sep 2013 15:29:52 -0700

> skb->data already points to IP header, but for the sake of
> consistency we can also use ip_hdr() to retrieve it.
> 
> Signed-off-by: Ansis Atteka <aatteka@nicira.com>

Applied.
