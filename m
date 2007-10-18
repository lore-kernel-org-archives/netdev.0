From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/7] Consolidate frag queues freeing
Date: Wed, 17 Oct 2007 19:48:36 -0700 (PDT)
Message-ID: <20071017.194836.32094913.davem@davemloft.net>
References: <4714C0AF.1000209@openvz.org>
	<4714C59E.50209@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60690
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1759417AbXJRCsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Oct 2007 22:48:37 -0400
In-Reply-To: <4714C59E.50209@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 16 Oct 2007 18:07:26 +0400

> Since we now allocate the queues in inet_fragment.c, we
> can safely free it in the same place. The ->destructor
> callback thus becomes optional for inet_frags.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Also applied, thanks a lot Pavel!
