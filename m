From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] mISDN: DSP scheduling fix
Date: Wed, 25 Apr 2012 20:38:30 -0400 (EDT)
Message-ID: <20120425.203830.1009996287981308109.davem@davemloft.net>
References: <1335271912-5269-1-git-send-email-kkeil@linux-pingi.de>
	<1335271912-5269-5-git-send-email-kkeil@linux-pingi.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, isdn@linux-pingi.de
To: kkeil@linux-pingi.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:55273 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932686Ab2DZAif (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 20:38:35 -0400
In-Reply-To: <1335271912-5269-5-git-send-email-kkeil@linux-pingi.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <kkeil@linux-pingi.de>
Date: Tue, 24 Apr 2012 14:51:52 +0200

> -u32	dsp_spl_jiffies; /* calculate the next time to fire */
> +ulong	dsp_spl_jiffies; /* calculate the next time to fire */

Please explicitly use "unsigned long", not "ulong".
