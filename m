From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net: fix missing pneigh entries in the neighbor
 seq_file code
Date: Sun, 03 Aug 2008 01:11:16 -0700 (PDT)
Message-ID: <20080803.011116.145945086.davem@davemloft.net>
References: <1217627389-9653-1-git-send-email-clarson@mvista.com>
	<1217627389-9653-2-git-send-email-clarson@mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: clarson@mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55143
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752997AbYHCILP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2008 04:11:15 -0400
In-Reply-To: <1217627389-9653-2-git-send-email-clarson@mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chris Larson <clarson@mvista.com>
Date: Fri,  1 Aug 2008 14:49:49 -0700

> When pneigh entries exist, but the user's read buffer isn't sufficient to
> hold them all, one of the pneigh entries will be missing from the results.
> 
> In neigh_get_idx_any, the number of elements which neigh_get_idx
> encountered is not correctly subtracted from the position number before
> the call to pneigh_get_idx.  neigh_get_idx reduces the position by 1 for
> each call to neigh_get_next, but it does not reduce it by one for the
> first element (neigh_get_first). The patch alters the neigh_get_idx and
> pneigh_get_idx functions to subtract one from pos, for the first element,
> when pos is non-zero.
> 
> Signed-off-by: Chris Larson <clarson@mvista.com>

This looks good too, applied.

Thanks Chris.
