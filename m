From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/8] mISDN: Allow to set a minimum length for
 transparent data
Date: Wed, 16 May 2012 01:18:54 -0400 (EDT)
Message-ID: <20120516.011854.1062044943070500943.davem@davemloft.net>
References: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de>
	<1337142174-8304-7-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45485 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965400Ab2EPFS7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 01:18:59 -0400
In-Reply-To: <1337142174-8304-7-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Wed, 16 May 2012 06:22:52 +0200

> @@ -197,7 +234,7 @@ recv_Echannel(struct dchannel *ech, struct dchannel *dch)
>  EXPORT_SYMBOL(recv_Echannel);
>  
>  void
> -recv_Bchannel(struct bchannel *bch, unsigned int id)
> +recv_Bchannel(struct bchannel *bch, unsigned int id, unsigned int force)

Please use "bool" for boolean variables.
