From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NET] Convert init_timer into setup_timer
Date: Tue, 13 Nov 2007 05:34:21 -0800 (PST)
Message-ID: <20071113.053421.68786227.davem@davemloft.net>
References: <4739A22B.20600@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46906
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751637AbXKMNeW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 08:34:22 -0500
In-Reply-To: <4739A22B.20600@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Tue, 13 Nov 2007 16:10:03 +0300

> Many-many code in the kernel initialized the timer->function 
> and  timer->data together with calling init_timer(timer). There 
> is already a helper for this. Use it for networking code.
> 
> The patch is HUGE, but makes the code 130 lines shorter 
> (98 insertions(+), 228 deletions(-)).
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

I have no objection to this patch, but it is 2.6.25
material for sure.
