From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] Hide the queue_mapping field inside
 netif_subqueue_stopped
Date: Sun, 21 Oct 2007 17:02:05 -0700 (PDT)
Message-ID: <20071021.170205.89148227.davem@davemloft.net>
References: <471871E5.7060900@openvz.org>
	<4718730D.1030801@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52733
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751299AbXJVABw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2007 20:01:52 -0400
In-Reply-To: <4718730D.1030801@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Fri, 19 Oct 2007 13:04:13 +0400

> Many places get the queue_mapping field from skb to pass it
> to the netif_subqueue_stopped() which will be 0 in any case.
> 
> Make the helper that works with sk_buff
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Applied, thanks!
