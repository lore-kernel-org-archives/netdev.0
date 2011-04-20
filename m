From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 8/8] sctp: Release all routes when
 processing acks ADD_IP or DEL_IP
Date: Tue, 19 Apr 2011 21:47:47 -0700 (PDT)
Message-ID: <20110419.214747.58452484.davem@davemloft.net>
References: <4DAD18AB.3040401@cn.fujitsu.com>
	<4DAD1A6A.1090805@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54835
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751412Ab1DTEsW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 00:48:22 -0400
In-Reply-To: <4DAD1A6A.1090805@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Tue, 19 Apr 2011 13:15:22 +0800

> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> When processing an ACK for ADD_IP parameter, we only release
> the routes on non-active transports.  This can cause a wrong
> source address to be used.  We can release the routes and
> cause new route lookups and source address selection so that
> new addresses can be used as source.  Additionally, we don't need
> to lookup routes for all transports at the same time.  We can let
> the transmit code path update the cached route when the transport
> actually sends something.
> 
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>

Applied.
