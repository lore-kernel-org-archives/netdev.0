From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] inet: rename some inet_sock fields
Date: Sun, 18 Oct 2009 18:54:07 -0700 (PDT)
Message-ID: <20091018.185407.193720322.davem@davemloft.net>
References: <4AD74E35.9080004@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47237
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750918AbZJSBxo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 21:53:44 -0400
In-Reply-To: <4AD74E35.9080004@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 15 Oct 2009 18:30:45 +0200

> In order to have better cache layouts of struct sock (separate zones
> for rx/tx paths), we need this preliminary patch.
> 
> Goal is to transfert fields used at lookup time in the first
> read-mostly cache line (inside struct sock_common) and move sk_refcnt
> to a separate cache line (only written by rx path)
> 
> This patch adds inet_ prefix to daddr, rcv_saddr, dport, num, saddr,
> sport and id fields. This allows a future patch to define these
> fields as macros, like sk_refcnt, without name clashes.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, thanks.
