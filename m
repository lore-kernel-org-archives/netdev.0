From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] sctp: Fix a race between ICMP protocol unreachable
 and connect()
Date: Sun, 16 May 2010 00:46:52 -0700 (PDT)
Message-ID: <20100516.004652.24579064.davem@davemloft.net>
References: <1273088166-18391-1-git-send-email-vladislav.yasevich@hp.com>
	<4BE775C7.9070702@cn.fujitsu.com>
	<4BE81144.8020806@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42567
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751238Ab0EPHqp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 03:46:45 -0400
In-Reply-To: <4BE81144.8020806@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 10 May 2010 09:59:32 -0400

> 
> 
> Wei Yongjun wrote:
>> [PATCH] sctp: delete active ICMP proto unreachable timer when free transport
>> 
>> transport may be free before ICMP proto unreachable timer expire, so
>> we should delete active ICMP proto unreachable timer when transport
>> is going away.
>> 
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
 ...
> ACK.  This fixes a race against close().  Although that will be fairly hard to
> do, it is possible.
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks.
