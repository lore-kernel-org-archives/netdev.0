From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix potential panics in the SCTP-AUTH API.
Date: Thu, 21 Aug 2008 03:35:44 -0700 (PDT)
Message-ID: <20080821.033544.193697878.davem@davemloft.net>
References: <20080820124145.f971f318.akpm@linux-foundation.org>
	<1219287458413-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	security@kernel.org, tk@trapkit.de
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46975
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752837AbYHUKfp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Aug 2008 06:35:45 -0400
In-Reply-To: <1219287458413-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Wed, 20 Aug 2008 22:57:38 -0400

> sctp: fix potential panics in the SCTP-AUTH API.
> 
> All of the SCTP-AUTH socket options could cause a panic
> if the extension is disabled and the API is envoked.
> 
> Additionally, there were some additional assumptions that
> certain pointers would always be valid which may not
> always be the case.
> 
> This patch hardens the API and address all of the crash
> scenarios.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks for working on this so quickly Vlad.

I'll queue this up for -stable.
