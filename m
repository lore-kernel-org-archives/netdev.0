From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v4] r8169: Disable force bus mastering
Date: Mon, 01 Feb 2016 11:36:56 -0800 (PST)
Message-ID: <20160201.113656.1945696793356724260.davem@davemloft.net>
References: <1454333896-2609-1-git-send-email-asd@marian1000.go.ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: asd@marian1000.go.ro
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41751 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752875AbcBATg7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2016 14:36:59 -0500
In-Reply-To: <1454333896-2609-1-git-send-email-asd@marian1000.go.ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Corcodel Marian <asd@marian1000.go.ro>
Date: Mon,  1 Feb 2016 15:38:16 +0200

> Do not need to force on bus mastering , if alls is ok this is
> enabled on BIOS.
> 
> Signed-off-by: Corcodel Marian <asd@marian1000.go.ro>

The chip can be used on systems without a BIOS and that should still
work.

The driver must fully program the card.

I'm not applying this.
