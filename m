From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6 2/2] ipv6: minor cleanup in net/ipv6/tcp_ipv6.c
 (RESEND).
Date: Tue, 17 Jun 2008 21:15:35 -0700 (PDT)
Message-ID: <20080617.211535.224387893.davem@davemloft.net>
References: <eb3ff54b0806162322n3952164cm7ab9f1749a52b2de@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ramirose@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55468
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750994AbYFREPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jun 2008 00:15:34 -0400
In-Reply-To: <eb3ff54b0806162322n3952164cm7ab9f1749a52b2de@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Rami Rosen" <ramirose@gmail.com>
Date: Tue, 17 Jun 2008 09:22:53 +0300

> In net/ipv6/tcp_ipv6.c:
> 
> 1) Remove unneeded tcp_v6_send_check() declaration.
> 
> 2) Unify two consecutive #ifdef CONFIG_TCP_MD5SIG (with nothing in
>   between them) into one #ifdef CONFIG_TCP_MD5SIG.
>
> Signed-off-by: Rami Rosen <ramirose@gmail.com>

Rami, I was going to apply this to net-next-2.6

The MD5 code changed a bit and in fact that
sequence of local variables then code with ifdef
protection isn't even there any more.

Could you respin this patch against net-next-2.6,
just the #1 part?

Thanks!
