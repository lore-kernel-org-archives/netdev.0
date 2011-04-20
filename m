From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bnx2x: dont dereference tcp header on non tcp frames
Date: Wed, 20 Apr 2011 01:46:57 -0700 (PDT)
Message-ID: <20110420.014657.232735224.davem@davemloft.net>
References: <1303229503.3480.386.camel@edumazet-laptop>
	<1303284713.3186.13.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dmitry@broadcom.com, eilong@broadcom.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54272
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752740Ab1DTIrb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:47:31 -0400
In-Reply-To: <1303284713.3186.13.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 20 Apr 2011 09:31:53 +0200

> [PATCH] bnx2x: dont dereference tcp header on non tcp frames
> 
> bnx2x_set_pbd_csum() & bnx2x_set_pbd_csum_e2() use 
> tcp_hdrlen(skb) even for non TCP frames
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Broadcom folks please review.
