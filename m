From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 3/4] caif-shm: Bugfixes for caif_shmcore.c
Date: Tue, 06 Dec 2011 13:27:08 -0500 (EST)
Message-ID: <20111206.132708.2022262299155263919.davem@davemloft.net>
References: <1323175740-1952-1-git-send-email-sjur.brandeland@stericsson.com>
	<1323175740-1952-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751934Ab1LFS1N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Dec 2011 13:27:13 -0500
In-Reply-To: <1323175740-1952-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Tue,  6 Dec 2011 13:48:59 +0100

> - don't call dev_kfree_skb() with irqs disabled,
>   use dev_kfree_skb_any() instead.

You unconditionally will always have IRQs disabled here, therefore
use dev_kfree_skb_irq() and avoid a test.
