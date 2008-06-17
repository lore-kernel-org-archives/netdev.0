From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] raw: Restore /proc/net/raw correct behavior
Date: Mon, 16 Jun 2008 17:04:24 -0700 (PDT)
Message-ID: <20080616.170424.09748097.davem@davemloft.net>
References: <4854ED6E.2060602@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: den@openvz.org, netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45253
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751355AbYFQAEY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 20:04:24 -0400
In-Reply-To: <4854ED6E.2060602@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Sun, 15 Jun 2008 12:22:38 +0200

> I just noticed "cat /proc/net/raw" was buggy, missing '\n' separators.
> 
> I believe this was introduced by commit 8cd850efa4948d57a2ed836911cfd1ab299e89c6 
> ([RAW]: Cleanup IPv4 raw_seq_show.)
> 
> This trivial patch restores correct behavior, and applies to current 
> Linus tree (should also be applied to stable tree as well.)
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied and queued up for -stable, thanks Eric!
