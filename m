From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] packet: fix possible dev refcnt leak when bind fail
Date: Tue, 27 Dec 2011 22:33:06 -0500 (EST)
Message-ID: <20111227.223306.2138114159772004875.davem@davemloft.net>
References: <CAPgLHd98WPb3ieuka-qT50Va+Fx+YBroF92AfuAmKGW9a8-AKQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: weiyj.lk@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51730 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753178Ab1L1DdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 22:33:13 -0500
In-Reply-To: <CAPgLHd98WPb3ieuka-qT50Va+Fx+YBroF92AfuAmKGW9a8-AKQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <weiyj.lk@gmail.com>
Date: Wed, 28 Dec 2011 10:53:05 +0800

> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> 
> If bind is fail when bind is called after set PACKET_FANOUT
> sock option, the dev refcnt will leak.
> 
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>

Applied, thanks a lot.
