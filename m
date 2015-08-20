From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1 0/6] Add fec1 and fec2 support for i.MX7d sdb board
Date: Thu, 20 Aug 2015 14:05:31 -0700 (PDT)
Message-ID: <20150820.140531.1320709021949935376.davem@davemloft.net>
References: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shawnguo@kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org
To: b38611@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751849AbbHTVFc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2015 17:05:32 -0400
In-Reply-To: <1439962444-27486-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fugang Duan <b38611@freescale.com>
Date: Wed, 19 Aug 2015 13:33:58 +0800

> The patch series is to add fec support for i.MX7d sdb board. Since i.MX7d fec ip is
> the same as i.MX6SX, so there have no change for driver itself.
> 
> Patch#1: add bcm54220 PHY ID entry into brcmphy.h file.

This is completely, and utterly, pointless.

The only reason a PHY ID should be defined in brcmphy.h is so that it can
be used in the broadcom.c PHY driver or similar.

If there is no user in the tree, there is no reason to add it to the
header file.
