From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] sctp: Drop ICMP packet too big message with MTU
 larger than current PMTU
Date: Thu, 23 Oct 2008 01:00:02 -0700 (PDT)
Message-ID: <20081023.010002.179974041.davem@davemloft.net>
References: <1224641327-11913-1-git-send-email-vladislav.yasevich@hp.com>
	<1224641327-11913-2-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38261
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751631AbYJWIAY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Oct 2008 04:00:24 -0400
In-Reply-To: <1224641327-11913-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Tue, 21 Oct 2008 22:08:44 -0400

> If ICMP packet too big message is received with MTU larger than current
> PMTU, SCTP will still accept this ICMP message and sync the PMTU of assoc
> with the wrong MTU.
> 
> Endpoing A                 Endpoint B
> (ESTABLISHED)              (ESTABLISHED)
> ICMP         --------->
> (packet too big, MTU too larger)
>                            sync PMTU
> 
> This patch fixed the problem by drop that ICMP message.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
