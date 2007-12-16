From: David Miller <davem@davemloft.net>
Subject: Re: [PACKET]: Fix /proc/net/packet crash due to bogus private
 pointer
Date: Sun, 16 Dec 2007 14:04:25 -0800 (PST)
Message-ID: <20071216.140425.19234188.davem@davemloft.net>
References: <200712160118.58611.m.kozlowski@tuxland.pl>
	<E1J3jqN-0000Jq-00@gondolin.me.apana.org.au>
	<20071216034119.GA1491@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: m.kozlowski@tuxland.pl, akpm@linux-foundation.org,
	jgarzik@pobox.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, den@openvz.org, xemul@openvz.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1764345AbXLPWEw@vger.kernel.org>
In-Reply-To: <20071216034119.GA1491@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sun, 16 Dec 2007 11:41:20 +0800

> [PACKET]: Fix /proc/net/packet crash due to bogus private pointer
> 
> The seq_open_net patch changed the meaning of seq->private.
> Unfortunately it missed two spots in AF_PACKET, which still
> used the old way of dereferencing seq->private, thus causing
> weird and wonderful crashes when reading /proc/net/packet.
> 
> This patch fixes them.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.25, thanks Herbert.
