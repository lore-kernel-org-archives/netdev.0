From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] tc35815: Fix return value of tc35815_do_interrupt
 when NAPI enabled
Date: Wed, 28 Oct 2009 03:57:06 -0700 (PDT)
Message-ID: <20091028.035706.19200503.davem@davemloft.net>
References: <1256564782-2781-1-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50338
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750748AbZJ1K4p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 06:56:45 -0400
In-Reply-To: <1256564782-2781-1-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Mon, 26 Oct 2009 22:46:21 +0900

> Return received count correctly even if tx completed at the same time.
> Currently NAPI is disabled for this driver so this patch does not fix
> any real problem.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied.
