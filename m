From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH] can: provide library functions for skb allocation
Date: Sun, 18 Oct 2009 20:46:17 +0200
Message-ID: <4ADB6279.3000403@grandegger.com>
References: <4AD6E9CA.3070605@grandegger.com> <20091017.235520.265660027.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, socketcan-core@lists.berlios.de,
	haas@ems-wuensche.com, anantgole@ti.com, mkl@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-out.m-online.net ([212.18.0.9]:59393 "EHLO
	mail-out.m-online.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754951AbZJRSqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 14:46:42 -0400
In-Reply-To: <20091017.235520.265660027.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Wolfgang Grandegger <wg@grandegger.com>
> Date: Thu, 15 Oct 2009 11:22:18 +0200
> 
>> +	skb->protocol = __constant_htons(ETH_P_CAN);
> 
> Please don't use __constant_htonX() for runtime invocatios.
> It's only for situation which must be compile time evaluations
> such as case statements and static initializations.
> 
> GCC can figure out that's it's constant if you just use
> plan htonX().

OK, I just dent out v2 of this patch.

Wolfgang.
