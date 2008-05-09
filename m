From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [SCTP]: Do not enable peer IPv6 address support on
 PF_INET socket
Date: Fri, 09 May 2008 15:11:26 -0700 (PDT)
Message-ID: <20080509.151126.02367630.davem@davemloft.net>
References: <1210360195-16524-1-git-send-email-vladislav.yasevich@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, yjwei@cn.fujitsu.com
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47157
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758985AbYEIWLc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 May 2008 18:11:32 -0400
In-Reply-To: <1210360195-16524-1-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Fri,  9 May 2008 15:09:54 -0400

> If socket is create by PF_INET type, it can not used IPv6 address to
> send/recv DATA, So we can not used IPv6 address even if peer tell us it
> support IPv6 address.
> This patch fix to only enabled peer IPv6 address support on PF_INET6 socket.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
