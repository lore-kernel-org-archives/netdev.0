From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/53] netns xfrm: per-netns state GC list
Date: Tue, 25 Nov 2008 17:20:19 -0800 (PST)
Message-ID: <20081125.172019.113556635.davem@davemloft.net>
References: <1227634045-27534-9-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-10-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-11-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59016
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752348AbYKZBUU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 20:20:20 -0500
In-Reply-To: <1227634045-27534-11-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:26:43 +0300

> km_waitq is going to be made per-netns to disallow spurious wakeups
> in __xfrm_lookup().
> 
> To not wakeup after every garbage-collected xfrm_state (which potentially
> can be from different netns) make state GC list per-netns.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.
