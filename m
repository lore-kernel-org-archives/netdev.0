From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Explicitly call fib_get_table() in fib_frontend.c
Date: Tue, 23 Oct 2007 21:17:36 -0700 (PDT)
Message-ID: <20071023.211736.35012964.davem@davemloft.net>
References: <471CC814.9040002@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devel@openvz.org
To: xemul@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752118AbXJXERw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 00:17:52 -0400
In-Reply-To: <471CC814.9040002@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pavel Emelyanov <xemul@openvz.org>
Date: Mon, 22 Oct 2007 19:56:04 +0400

> In case the "multiple tables" config option is y, the ip_fib_local_table
> is not a variable, but a macro, that calls fib_get_table(RT_TABLE_LOCAL).
> 
> Some code uses this "variable" *3* times in one place, thus implicitly
> making 3 calls. Fix it.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Good catch, applied.
