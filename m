From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/7] Omit double hash calculations in xxx_frag_intern
Date: Wed, 17 Oct 2007 19:44:10 -0700 (PDT)
Message-ID: <20071017.194410.102574145.davem@davemloft.net>
References: <4714C0AF.1000209@openvz.org>
	<4714C13E.3040808@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35822
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751305AbXJRCoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:44:12 -0400
In-Reply-To: <4714C13E.3040808@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 16 Oct 2007 17:48:46 +0400

> Since the hash value is already calculated in xxx_find, we can 
> simply use it later. This is already done in netfilter code, 
> so make the same in ipv4 and ipv6.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, but if we ever implement dynamically sized frag
queue hash tables, this recomputation of the hash function
in the hash insert function would need to be re-added.
