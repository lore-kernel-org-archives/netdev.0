From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 53/53] netns xfrm: per-netns sysctls
Date: Tue, 25 Nov 2008 18:00:56 -0800 (PST)
Message-ID: <20081125.180056.219103599.davem@davemloft.net>
References: <1227634045-27534-51-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-52-git-send-email-adobriyan@gmail.com>
	<1227634045-27534-53-git-send-email-adobriyan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, kuznet@ms2.inr.ac.ru,
	netdev@vger.kernel.org, containers@lists.linux-foundation.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57414
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752887AbYKZCA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2008 21:00:57 -0500
In-Reply-To: <1227634045-27534-53-git-send-email-adobriyan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 25 Nov 2008 20:27:25 +0300

> Make
> 	net.core.xfrm_aevent_etime
> 	net.core.xfrm_acq_expires
> 	net.core.xfrm_aevent_rseqth
> 	net.core.xfrm_larval_drop
> 
> sysctls per-netns.
> 
> For that make net_core_path[] global, register it to prevent two
> /proc/net/core antries and change initcall position -- xfrm_init() is called
> from fs_initcall, so this one should be fs_initcall at least.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Applied.

Thanks a lot Alexey.
