From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Ensure that pneigh_lookup is protected with RTNL
Date: Mon, 15 Oct 2007 12:54:35 -0700 (PDT)
Message-ID: <20071015.125435.08669923.davem@davemloft.net>
References: <47136D71.4000108@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46170
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932956AbXJOTye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 15:54:34 -0400
In-Reply-To: <47136D71.4000108@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 15 Oct 2007 17:38:57 +0400

> The pnigh_lookup is used to lookup proxy entries and to 
> create them in case lookup failed. 
> 
> However, the "creation" code does not perform the re-lookup
> after GFP_KERNEL allocation. This is done because the code
> is expected to be protected with the RTNL lock, so add the 
> assertion (mainly to address future questions from new network 
> developers like me :) ).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thanks for this patch, applied.
