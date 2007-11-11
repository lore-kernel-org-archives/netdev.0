From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RESEND] small possible memory leak in FIB rules
Date: Sat, 10 Nov 2007 22:12:17 -0800 (PST)
Message-ID: <20071110.221217.39233934.davem@davemloft.net>
References: <20071107133636.GA10719@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: devel@openvz.org, containers@lists.osdl.org, netdev@vger.kernel.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58931
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751745AbXKKGMS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Nov 2007 01:12:18 -0500
In-Reply-To: <20071107133636.GA10719@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Denis V. Lunev" <den@openvz.org>
Date: Wed, 7 Nov 2007 16:36:36 +0300

> This patch fixes a small memory leak. Default fib rules can be deleted by
> the user if the rule does not carry FIB_RULE_PERMANENT flag, f.e. by
> 	ip rule flush
> 
> Such a rule will not be freed as the ref-counter has 2 on start and becomes
> clearly unreachable after removal.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>
> Acked-by: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>

Applied, thanks Denis.
