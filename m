From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: do not leak net_generic data on failed init
Date: Tue, 17 Apr 2012 22:32:52 -0400 (EDT)
Message-ID: <20120417.223252.1031504118018410756.davem@davemloft.net>
References: <1334587395-6033-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ebiederm@xmission.com
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:32839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599Ab2DRCdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Apr 2012 22:33:03 -0400
In-Reply-To: <1334587395-6033-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Mon, 16 Apr 2012 17:43:15 +0300

> 	ops_init should free the net_generic data on
> init failure and __register_pernet_operations should not
> call ops_free when NET_NS is not enabled.
> 
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Eric please review this patch.
