From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mISDN: Bugfix for layer2 fixed TEI mode
Date: Mon, 06 Aug 2012 13:27:30 -0700 (PDT)
Message-ID: <20120806.132730.1234170287546038559.davem@davemloft.net>
References: <1344075265-18999-1-git-send-email-keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stable@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de
To: keil@b1-systems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38842 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755937Ab2HFU1i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 16:27:38 -0400
In-Reply-To: <1344075265-18999-1-git-send-email-keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <keil@b1-systems.de>
Date: Sat,  4 Aug 2012 12:14:25 +0200

> If a fixed TEI is used, the initial state of the layer 2 statmachine need to be
> 4 (TEI assigned). This was true only for Point to Point connections, but not
> for the other fixed TEIs. It was not found before, because usually only the
> TEI 0 is used as fixed TEI for PtP mode, but if you try X31 packet mode
> connections with SAPI 16, TEI 1, it did fail.
> 
> Signed-off-by: Karsten Keil <keil@b1-systems.de>
> Cc: <stable@vger.kernel.org> # 3.5.x

Applied.
