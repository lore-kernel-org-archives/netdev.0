From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/5] tc35815: Improve BLEx / FDAEx handling
Date: Thu, 06 Aug 2009 13:16:38 -0700 (PDT)
Message-ID: <20090806.131638.255582209.davem@davemloft.net>
References: <1249569709-21403-2-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42434
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756674AbZHFUQ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 16:16:29 -0400
In-Reply-To: <1249569709-21403-2-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Thu,  6 Aug 2009 23:41:46 +0900

> Clear Int_BLEx / Int_FDAEx after (not before) processing Rx interrupt.
> This will reduce number of unnecessary interrupts.
> Also print rx error messages only if netif_msg_rx_err() enabled.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied to net-next-2.6
