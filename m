From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af_unix should update its inuse counter
Date: Mon, 17 Nov 2008 02:39:12 -0800 (PST)
Message-ID: <20081117.023912.186227423.davem@davemloft.net>
References: <492142DD.2030906@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53624
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751945AbYKQKjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Nov 2008 05:39:13 -0500
In-Reply-To: <492142DD.2030906@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 17 Nov 2008 11:09:33 +0100

Applied, thanks Eric.

> +	else
> +		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, 1);
> +		

That last line had trailing whitespace, which I fixed up.
