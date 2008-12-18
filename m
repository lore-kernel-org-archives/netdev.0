From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ppp_generic - use idr technique instead of
 cardmaps
Date: Wed, 17 Dec 2008 17:41:02 -0800 (PST)
Message-ID: <20081217.174102.121955000.davem@davemloft.net>
References: <20081216192000.GF26390@localhost>
	<20081217171625.776d4e46.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gorcunov@gmail.com, paulus@samba.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, xemul@openvz.org
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35326
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750817AbYLRBlA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 20:41:00 -0500
In-Reply-To: <20081217171625.776d4e46.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Wed, 17 Dec 2008 17:16:25 -0800

> What is the locking for the IDR tree?  all_ppp_mutex?

Yes.
