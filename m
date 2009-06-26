From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: missing check ACK flag of received segment in
 FIN-WAIT-2 state
Date: Thu, 25 Jun 2009 20:09:40 -0700 (PDT)
Message-ID: <20090625.200940.99884468.davem@davemloft.net>
References: <4A43356B.7060005@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48332
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752433AbZFZDJf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jun 2009 23:09:35 -0400
In-Reply-To: <4A43356B.7060005@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Thu, 25 Jun 2009 16:29:31 +0800

> RFC0793 defined that in FIN-WAIT-2 state if the ACK bit is off drop
> the segment and return[Page 72]. But this check is missing in function
> tcp_timewait_state_process(). This cause the segment with FIN flag but
> no ACK has two diffent action:
...
> This patch fixed the problem.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Patch applied, thank you.
