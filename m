From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] sctp: Fix to handle SHUTDOWN in SHUTDOWN_RECEIVED
 state
Date: Thu, 23 Oct 2008 01:01:26 -0700 (PDT)
Message-ID: <20081023.010126.69738776.davem@davemloft.net>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
	<1224641327-11913-5-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38273
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752725AbYJWIBt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 04:01:49 -0400
In-Reply-To: <1224641327-11913-5-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 21 Oct 2008 22:08:47 -0400

> Once an endpoint has reached the SHUTDOWN-RECEIVED state,
> it MUST NOT send a SHUTDOWN in response to a ULP request.
> The Cumulative TSN Ack of the received SHUTDOWN chunk
> MUST be processed.
> 
> This patch fix to process Cumulative TSN Ack of the received
> SHUTDOWN chunk in SHUTDOWN_RECEIVED state.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
