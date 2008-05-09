From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SCTP]: Add address type check while process
 paramaters of ASCONF chunk
Date: Fri, 09 May 2008 15:12:03 -0700 (PDT)
Message-ID: <20080509.151203.84367922.davem@davemloft.net>
References: <1210360195-16524-1-git-send-email-vladislav.yasevich@hp.com>
	<1210360195-16524-2-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47162
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754908AbYEIWMJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:12:09 -0400
In-Reply-To: <1210360195-16524-2-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  9 May 2008 15:09:55 -0400

> If socket is create by AF_INET type, add IPv6 address to asoc will cause
> kernel panic while packet is transmitted on that transport.
> 
> This patch add address type check before process paramaters of ASCONF
> chunk. If peer is not support this address type, return with error
> invald parameter.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied, thanks.
