From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][LRO] Fix lro_mgr->features checks
Date: Mon, 07 Jan 2008 22:09:28 -0800 (PST)
Message-ID: <20080107.220928.211341509.davem@davemloft.net>
References: <47822A2C.4020303@inria.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: gallatin@myri.com, themann@de.ibm.com, torvalds@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Brice.Goglin@inria.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38578
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755040AbYAHGJ3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 01:09:29 -0500
In-Reply-To: <47822A2C.4020303@inria.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <Brice.Goglin@inria.fr>
Date: Mon, 07 Jan 2008 14:33:32 +0100

> [PATCH][LRO] Fix lro_mgr->features checks
> 
> lro_mgr->features contains a bitmask of LRO_F_* values which are
> defined as power of two, not as bit indexes.
> They must be checked with x&LRO_F_FOO, not with test_bit(LRO_F_FOO,&x).
> 
> Signed-off-by: Brice Goglin <Brice.Goglin@inria.fr>
> Acked-by: Andrew Gallatin <gallatin@myri.com>

Applied, thanks a lot.
