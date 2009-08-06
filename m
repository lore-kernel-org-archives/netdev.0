From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 5/5] tc35815: Use 0 RxFragSize.MinFrag value for
 non-packing mode
Date: Thu, 06 Aug 2009 13:17:07 -0700 (PDT)
Message-ID: <20090806.131707.54871209.davem@davemloft.net>
References: <1249569709-21403-5-git-send-email-anemo@mba.ocn.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ralf.roesch@rw-gmbh.de
To: anemo@mba.ocn.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42448
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756576AbZHFUQ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Aug 2009 16:16:57 -0400
In-Reply-To: <1249569709-21403-5-git-send-email-anemo@mba.ocn.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Atsushi Nemoto <anemo@mba.ocn.ne.jp>
Date: Thu,  6 Aug 2009 23:41:49 +0900

> The datasheet say "When not enabling packing, the MinFrag value must
> remain at 0".  Do not set value to RxFragSize register if
> TC35815_USE_PACKEDBUFFER disabled.
> 
> This is not a bugfix.  No real problem reported on this.
> 
> Signed-off-by: Atsushi Nemoto <anemo@mba.ocn.ne.jp>

Applied to net-next-2.6
