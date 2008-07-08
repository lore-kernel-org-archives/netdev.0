From: David Miller <davem@davemloft.net>
Subject: Re: [bug?] tg3: Failed to load firmware "tigon/tg3_tso.bin"
Date: Tue, 08 Jul 2008 01:57:01 -0700 (PDT)
Message-ID: <20080708.015701.249196626.davem@davemloft.net>
References: <20080707221427.163c4a30@the-village.bc.nu>
	<20080707.145819.209342070.davem@davemloft.net>
	<20080708073637.32037c76@the-village.bc.nu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, dwmw2@infradead.org, andi@firstfloor.org,
	tytso@mit.edu, hugh@veritas.com, akpm@linux-foundation.org,
	kosaki.motohiro@jp.fujitsu.com, mchan@broadcom.com,
	linux-kernel@vger.kernel.org, linux-mm@kvack.org,
	netdev@vger.kernel.org
To: alan@lxorguk.ukuu.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39243
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751900AbYGHI5B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2008 04:57:01 -0400
In-Reply-To: <20080708073637.32037c76@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Date: Tue, 8 Jul 2008 07:36:37 +0100

> > I can only see it being about separation, pure and simple.
> 
> Separation - of firmware that can be paged from code that cannot.

It can't be paged from the drivers we're talking about,
no matter how hard you try.

Every chip reset needs the firmware around so it can be
reloaded into the card.

This applies to tg3, bnx2, bnx2x, etc. etc. etc.

