From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fix build bug in 2.6.30-rc4:
 xt_socket.c:(.text+0x57780): undefined reference to
 `nf_conntrack_untracked'
Date: Thu, 30 Apr 2009 04:06:06 -0700 (PDT)
Message-ID: <20090430.040606.154074536.davem@davemloft.net>
References: <20090430075554.GA12204@elte.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@vyatta.com, kaber@trash.net,
	panther@balabit.hu, linux-kernel@vger.kernel.org
To: mingo@elte.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39092
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751335AbZD3LGM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 07:06:12 -0400
In-Reply-To: <20090430075554.GA12204@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ingo Molnar <mingo@elte.hu>
Date: Thu, 30 Apr 2009 09:55:54 +0200

>     Revert "netfilter: Kconfig: TProxy doesn't depend on NF_CONNTRACK"
>     
>     This reverts commit 4b0706624930dc75c3b0d0df463d89759ef7de29.

Thanks Ingo, I'll apply this revert soon unless Patrick wants to
handle it differently.
