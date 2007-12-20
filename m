From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25 8/9] SCTP: Implement ADD-IP special case
 processing for ABORT chunk
Date: Thu, 20 Dec 2007 14:13:07 -0800 (PST)
Message-ID: <20071220.141307.38109289.davem@davemloft.net>
References: <1197927169-5106-1-git-send-email-vladislav.yasevich@hp.com>
	<1197927169-5106-9-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39690
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753342AbXLTWNI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Dec 2007 17:13:08 -0500
In-Reply-To: <1197927169-5106-9-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 17 Dec 2007 16:32:48 -0500

> ADD-IP spec has a special case for processing ABORTs:
>     F4) ... One special consideration is that ABORT
>         Chunks arriving destined to the IP address being deleted MUST be
>         ignored (see Section 5.3.1 for further details).
> 
> Check if the address we received on is in the DEL state, and if
> so, ignore the ABORT.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
