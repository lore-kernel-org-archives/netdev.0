From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_key: fix info leaks in notify messages
Date: Wed, 26 Jun 2013 15:16:37 -0700 (PDT)
Message-ID: <20130626.151637.1956131728102073395.davem@davemloft.net>
References: <1372283550-29911-1-git-send-email-minipli@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: minipli@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752707Ab3FZWQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 18:16:37 -0400
In-Reply-To: <1372283550-29911-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Krause <minipli@googlemail.com>
Date: Wed, 26 Jun 2013 23:52:30 +0200

> key_notify_sa_flush() and key_notify_policy_flush() miss to initialize
> the sadb_msg_reserved member of the broadcasted message and thereby
> leak 2 bytes of heap memory to listeners. Fix that.
> 
> Signed-off-by: Mathias Krause <minipli@googlemail.com>

Applied and queued up for -stable, thanks!
