From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9] Small cleanup for xxx_put after evictor
 consolidation
Date: Mon, 15 Oct 2007 02:41:33 -0700 (PDT)
Message-ID: <20071015.024133.64825641.davem@davemloft.net>
References: <470F6EAE.60308@openvz.org>
	<470F764C.2070305@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39919
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757899AbXJOJl3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2007 05:41:29 -0400
In-Reply-To: <470F764C.2070305@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 12 Oct 2007 17:27:40 +0400

> After the evictor code is consolidated there is no need in 
> passing the extra pointer to the xxx_put() functions.
> 
> The only place when it made sense was the evictor code itself.
> 
> Maybe this change must got with the previous (or with the 
> next) patch, but I try to make them shorter as much as 
> possible to simplify the review (but they are still large 
> anyway), so this change goes in a separate patch.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied.
