From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] can: provide library functions for skb allocation
Date: Sat, 17 Oct 2009 23:55:20 -0700 (PDT)
Message-ID: <20091017.235520.265660027.davem@davemloft.net>
References: <4AD6E9CA.3070605@grandegger.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	haas@ems-wuensche.com, anantgole@ti.com, mkl@pengutronix.de
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33990
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751610AbZJRGy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 02:54:57 -0400
In-Reply-To: <4AD6E9CA.3070605@grandegger.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wolfgang Grandegger <wg@grandegger.com>
Date: Thu, 15 Oct 2009 11:22:18 +0200

> +	skb->protocol = __constant_htons(ETH_P_CAN);

Please don't use __constant_htonX() for runtime invocatios.
It's only for situation which must be compile time evaluations
such as case statements and static initializations.

GCC can figure out that's it's constant if you just use
plan htonX().
