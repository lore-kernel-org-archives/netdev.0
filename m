From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: in the first call to neigh_seq_next, call
 neigh_get_first, not neigh_get_idx.
Date: Sun, 03 Aug 2008 01:02:51 -0700 (PDT)
Message-ID: <20080803.010251.160221660.davem@davemloft.net>
References: <1217627389-9653-1-git-send-email-clarson@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: clarson@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44279
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752639AbYHCICv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 04:02:51 -0400
In-Reply-To: <1217627389-9653-1-git-send-email-clarson@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Larson <clarson@mvista.com>
Date: Fri,  1 Aug 2008 14:49:48 -0700

> neigh_seq_next won't be called both with *pos > 0 && v == SEQ_START_TOKEN,
> so there's no point calling neigh_get_idx when we're on the start token,
> just call neigh_get_first directly.
> 
> Signed-off-by: Chris Larson <clarson@mvista.com>

Applied, thanks Chris.
