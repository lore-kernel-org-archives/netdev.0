From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 1/3] ixgbe: support
 netdev_ops->ndo_xmit_flush()
Date: Sun, 24 Aug 2014 22:55:51 -0700 (PDT)
Message-ID: <20140824.225551.720302228613030489.davem@davemloft.net>
References: <1408887738-7661-1-git-send-email-dborkman@redhat.com>
	<1408887738-7661-2-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54348 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752505AbaHYFzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Aug 2014 01:55:52 -0400
In-Reply-To: <1408887738-7661-2-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Sun, 24 Aug 2014 15:42:16 +0200

> +	/* we need this if more than one processor can write to our tail
> +	 * at a time, it synchronizes IO on IA64/Altix systems
> +	 */
> +	mmiowb();

Unlike for IGB, this doesn't exist in the IXGBE driver, please do not add
it.
