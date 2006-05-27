From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.18 2/3] tg3: Add recovery logic when MMIOs are
 re-ordered
Date: Fri, 26 May 2006 17:48:26 -0700 (PDT)
Message-ID: <20060526.174826.88345694.davem@davemloft.net>
References: <1148684587.3930.9.camel@rh4>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:11744
	"EHLO sunset.sfo1.dsl.speakeasy.net") by vger.kernel.org with ESMTP
	id S932782AbWE0AsQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 26 May 2006 20:48:16 -0400
To: mchan@broadcom.com
In-Reply-To: <1148684587.3930.9.camel@rh4>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 26 May 2006 16:03:07 -0700

> Add recovery logic when we suspect that the system is re-ordering
> MMIOs. Re-ordered MMIOs to the send mailbox can cause bogus tx
> completions and hit BUG_ON() in the tx completion path.
 ...
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Looks good, applied.

