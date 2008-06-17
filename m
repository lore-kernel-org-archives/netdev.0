From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2 v2] sctp: Correclty set changeover_active for
 SFR-CACC
Date: Mon, 16 Jun 2008 17:01:19 -0700 (PDT)
Message-ID: <20080616.170119.12283602.davem@davemloft.net>
References: <1213365531-10049-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net,
	linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45245
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752486AbYFQABT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 20:01:19 -0400
In-Reply-To: <1213365531-10049-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 13 Jun 2008 09:58:51 -0400

> Not sure why the spacing got garbled in this patch, but here it
> again and looking much better.
> 
> --
> 
> Right now, any time we set a primary transport we set
> the changeover_active flag.  As a result, we invoke SFR-CACC
> even when there has been no changeover events.
> 
> Only set changeover_active, when there is a true changeover
> event, i.e. we had a primary path and we are changing to
> another transport.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied to net-2.6, thanks!
