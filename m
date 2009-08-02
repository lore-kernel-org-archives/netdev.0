From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] mISDN: Fix handling of receive buffer size in L1oIP
Date: Sun, 02 Aug 2009 13:02:38 -0700 (PDT)
Message-ID: <20090802.130238.264137595.davem@davemloft.net>
References: <cover.1248781021.git.keil@b1-systems.de>
	<467d0b871314c60818f541024fcacca686f3e354.1248781021.git.keil@b1-systems.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, i4ldeveloper@listserv.isdn4linux.de,
	andreas@eversberg.eu, acme@redhat.com
To: keil@b1-systems.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46864
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753047AbZHBUCa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 16:02:30 -0400
In-Reply-To: <467d0b871314c60818f541024fcacca686f3e354.1248781021.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karsten Keil <keil@b1-systems.de>
Date: Mon, 27 Jul 2009 19:24:04 +0200

> From: Andreas Eversberg <andreas@eversberg.eu>
> 
> The size of receive buffer pointer was used to get size of
> receive buffer instead of recvbuf_size itself, so only 4/8
> bytes could be transfered.
> 
> This is a regression to 2.6.30 introduced by commit 8c90e11e3543d7de612194a042a148caeaab5f1d
> mISDN: Use kernel_{send,recv}msg instead of open coding
> 
> Signed-off-by: Andreas Eversberg <andreas@eversberg.eu>
> Signed-off-by: Karsten Keil <keil@b1-systems.de>

Applied to net-2.6, thanks.

