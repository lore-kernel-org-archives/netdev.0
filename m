From: Mariusz Kozlowski <m.kozlowski@tuxland.pl>
Subject: Re: [PACKET]: Fix /proc/net/packet crash due to bogus private pointer
Date: Sun, 16 Dec 2007 11:48:27 +0100
Message-ID: <200712161148.28425.m.kozlowski@tuxland.pl>
References: <200712160118.58611.m.kozlowski@tuxland.pl> <E1J3jqN-0000Jq-00@gondolin.me.apana.org.au> <20071216034119.GA1491@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net, den@openvz.org, xemul@openvz.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xdsl-664.zgora.dialog.net.pl ([81.168.226.152]:1484 "EHLO
	tuxland.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757456AbXLPKqa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 16 Dec 2007 05:46:30 -0500
In-Reply-To: <20071216034119.GA1491@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

> Surprise surprise.  The namespace seq patch missed two spots in
> AF_PACKET.
> 
> [PACKET]: Fix /proc/net/packet crash due to bogus private pointer
> 
> The seq_open_net patch changed the meaning of seq->private.
> Unfortunately it missed two spots in AF_PACKET, which still
> used the old way of dereferencing seq->private, thus causing
> weird and wonderful crashes when reading /proc/net/packet.
> 
> This patch fixes them.

True :) It fixes both my x86 and sprac64. Thanks.

	Mariusz
