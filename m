From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Fix SCTP_SET_PEER_PRIMARY_ADDR to accpet
 v4mapped address
Date: Fri, 10 Dec 2010 15:29:58 -0800 (PST)
Message-ID: <20101210.152958.42812979.davem@davemloft.net>
References: <4CFEF74D.7020704@cn.fujitsu.com>
	<4D02B436.5000605@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yjwei@cn.fujitsu.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41640
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750929Ab0LJX3b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:29:31 -0500
In-Reply-To: <4D02B436.5000605@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladislav Yasevich <vladislav.yasevich@hp.com>
Date: Fri, 10 Dec 2010 18:13:58 -0500

> On 12/07/2010 10:11 PM, Wei Yongjun wrote:
>> SCTP_SET_PEER_PRIMARY_ADDR does not accpet v4mapped address, using
>> v4mapped address in SCTP_SET_PEER_PRIMARY_ADDR socket option will
>> get -EADDRNOTAVAIL error if v4map is enabled. This patch try to
>> fix it by mapping v4mapped address to v4 address if allowed.
>> 
>> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> 
> Looks good.
> 
> Acked-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks everyone.
