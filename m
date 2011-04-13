From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sctp: fix oops when updating retransmit path with
 DEBUG on
Date: Tue, 12 Apr 2011 19:34:00 -0700 (PDT)
Message-ID: <20110412.193400.189720071.davem@davemloft.net>
References: <4DA4FA70.50506@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35881
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753247Ab1DMCef (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 22:34:35 -0400
In-Reply-To: <4DA4FA70.50506@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Wed, 13 Apr 2011 09:20:48 +0800

> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> 
> commit fbdf501c9374966a56829ecca3a7f25d2b49a305
>   sctp: Do no select unconfirmed transports for retransmissions
> 
> Introduced the initial falt.
> 
> commit d598b166ced20d9b9281ea3527c0e18405ddb803
>   sctp: Make sure we always return valid retransmit path
> 
> Solved the problem, but forgot to change the DEBUG statement.
> Thus it was still possible to dereference a NULL pointer.
> 
> Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
> Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>

Applied.
