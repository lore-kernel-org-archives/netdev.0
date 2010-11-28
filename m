From: "Vladislav Zolotarov" <vladz@broadcom.com>
Subject: Re: [PATCH net-next] bnx2x: Use skb_is_gso_v6(skb) instead of
 accessing the skb_shinfo(skb) directly
Date: Sun, 28 Nov 2010 12:22:14 +0200
Message-ID: <1290939734.21703.78.camel@lb-tlvb-vladz>
References: <1290612078.27220.2.camel@lb-tlvb-vladz>
 <1290678762.18389.1.camel@lb-tlvb-vladz>
 <1290851625.2794.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Dave Miller" <davem@davemloft.net>,
	"Eilon Greenstein" <eilong@broadcom.com>,
	"netdev list" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:2815 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779Ab0K1KW0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 28 Nov 2010 05:22:26 -0500
In-Reply-To: <1290851625.2794.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 
> May I ask why ?
> 
> This seems not consistent with the previous block.
> 
> Either you also add a skb_is_gso_v4(skb) helper, or let the code as is,
> maybe reordering the flags ?
> 

U r right. I'm respinning a patch taking your remarks and a "brackets"
patch into an account.

thanks, Eric.


