From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/8] mISDN: Reduce RX buffer allocation for transparent
 data
Date: Wed, 16 May 2012 01:21:35 -0400 (EDT)
Message-ID: <20120516.012135.1833689708803796590.davem@davemloft.net>
References: <1337142174-8304-1-git-send-email-kkeil@linux-pingi.de>
	<1337142174-8304-6-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45499 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965132Ab2EPFVk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 01:21:40 -0400
In-Reply-To: <1337142174-8304-6-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Wed, 16 May 2012 06:22:51 +0200

>  EXPORT_SYMBOL(bchannel_senddata);
> +
> +/*
> + * The function allocates a new receive skb on demand with a size for the
> + * requirements of the current protocol. It returns the tailroom of the
> + * receive skb or an error.
> + */

Please format this comment:

	/* Like this,
	 * please.
	 */

Thank you.
