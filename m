From: David Miller <davem@davemloft.net>
Subject: Re: [-mm patch] net/: possible cleanups
Date: Thu, 30 Nov 2006 17:28:06 -0800 (PST)
Message-ID: <20061130.172806.125565481.davem@davemloft.net>
References: <20061123021703.8550e37e.akpm@osdl.org>
	<20061124215820.GI28363@stusta.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:14993
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1031717AbWLAB2E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 30 Nov 2006 20:28:04 -0500
To: bunk@stusta.de
In-Reply-To: <20061124215820.GI28363@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Adrian Bunk <bunk@stusta.de>
Date: Fri, 24 Nov 2006 22:58:20 +0100

> This patch contains the following possible cleanups:
> - make the following needlessly global functions statis:
>   - ipv4/tcp.c: __tcp_alloc_md5sig_pool()
>   - ipv4/tcp_ipv4.c: tcp_v4_reqsk_md5_lookup()
>   - ipv4/udplite.c: udplite_rcv()
>   - ipv4/udplite.c: udplite_err()
> - make the following needlessly global structs static:
>   - ipv4/tcp_ipv4.c: tcp_request_sock_ipv4_ops
>   - ipv4/tcp_ipv4.c: tcp_sock_ipv4_specific
>   - ipv6/tcp_ipv6.c: tcp_request_sock_ipv6_ops
> - net/ipv{4,6}/udplite.c: remove inline's from static functions
>                           (gcc should know best when to inline them)
> 
> Signed-off-by: Adrian Bunk <bunk@stusta.de>

Applied, thanks Adrian.
