From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Pull ip header into skb->data before looking
 into ip header.
Date: Wed, 10 Oct 2012 22:53:58 -0400 (EDT)
Message-ID: <20121010.225358.819989131525970516.davem@davemloft.net>
References: <6f6f2599-15e5-49a7-973c-d2c36483427d@CMEXHTCAS1.ad.emulex.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sarveshwar.bandi@emulex.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58905 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753599Ab2JKCx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2012 22:53:59 -0400
In-Reply-To: <6f6f2599-15e5-49a7-973c-d2c36483427d@CMEXHTCAS1.ad.emulex.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <sarveshwar.bandi@emulex.com>
Date: Wed, 10 Oct 2012 16:45:01 +0530

> From: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>
> 
> If lower layer driver leaves the ip header in the skb fragment, it needs to
> be first pulled into skb->data before inspecting ip header length or ip version
> number.
> 
> Signed-off-by: Sarveshwar Bandi <sarveshwar.bandi@emulex.com>

Applied.
