From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] SCTP: Fix SCTP_SET_PEER_PRIMARY_ADDR to accpet
 v4mapped address
Date: Fri, 10 Dec 2010 15:01:51 -0800 (PST)
Message-ID: <20101210.150151.45910848.davem@davemloft.net>
References: <4CFEF74D.7020704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vladislav.yasevich@hp.com, linux-sctp@vger.kernel.org,
	netdev@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45084
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753541Ab0LJXBX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Dec 2010 18:01:23 -0500
In-Reply-To: <4CFEF74D.7020704@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Wed, 08 Dec 2010 11:11:09 +0800

> SCTP_SET_PEER_PRIMARY_ADDR does not accpet v4mapped address, using
> v4mapped address in SCTP_SET_PEER_PRIMARY_ADDR socket option will
> get -EADDRNOTAVAIL error if v4map is enabled. This patch try to
> fix it by mapping v4mapped address to v4 address if allowed.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Vlad and other SCTP folks, please review this patch.
