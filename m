From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/3] sctp: Fix SNMP number of SCTP_MIB_ABORTED
 during violation handling.
Date: Thu, 09 Oct 2008 14:33:08 -0700 (PDT)
Message-ID: <20081009.143308.205088695.davem@davemloft.net>
References: <1223558975-1550-1-git-send-email-vladislav.yasevich@hp.com>
	<1223558975-1550-4-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47438
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1755443AbYJIVdc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2008 17:33:32 -0400
In-Reply-To: <1223558975-1550-4-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Thu,  9 Oct 2008 09:29:34 -0400

> If ABORT chunks require authentication and a protocol violation
> is triggered, we do not tear down the association.  Subsequently,
> we should not increment SCTP_MIB_ABORTED.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks.
