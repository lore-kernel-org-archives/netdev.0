From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] xfrm: Fix initialize repl field of struct xfrm_state
Date: Mon, 21 Mar 2011 18:08:59 -0700 (PDT)
Message-ID: <20110321.180859.245394202.davem@davemloft.net>
References: <4D8701C3.5010304@cn.fujitsu.com>
	<20110321.010037.59680394.davem@davemloft.net>
	<4D870E2F.50601@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48138
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754737Ab1CVBIV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 21:08:21 -0400
In-Reply-To: <4D870E2F.50601@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Yongjun <yjwei@cn.fujitsu.com>
Date: Mon, 21 Mar 2011 16:37:03 +0800

> Commit 'xfrm: Move IPsec replay detection functions to a separate file'
>   (9fdc4883d92d20842c5acea77a4a21bb1574b495)
> introduce repl field to struct xfrm_state, and only initialize it
> under SA's netlink create path, the other path, such as pf_key,
> ipcomp/ipcomp6 etc, the repl field remaining uninitialize. So if
> the SA is created by pf_key, any input packet with SA's encryption
> algorithm will cause panic.

I'll apply this, thanks.

I know you guys are discussing alternative ways to handle this,
but getting the crash fixed in the simplest way now doesn't hurt.
