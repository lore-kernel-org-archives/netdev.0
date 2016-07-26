From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] udp: use sk_filter_trim_cap for
 udp{,6}_queue_rcv_skb
Date: Mon, 25 Jul 2016 21:40:42 -0700 (PDT)
Message-ID: <20160725.214042.2053568298270455930.davem@davemloft.net>
References: <0a5ec5a7e99c314f5f5f56f37380b70f8a5bc4ad.1469462373.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemdebruijn.kernel@gmail.com,
	alexei.starovoitov@gmail.com, willemb@google.com
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52226 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753714AbcGZEkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jul 2016 00:40:43 -0400
In-Reply-To: <0a5ec5a7e99c314f5f5f56f37380b70f8a5bc4ad.1469462373.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Mon, 25 Jul 2016 18:06:12 +0200

> After a612769774a3 ("udp: prevent bugcheck if filter truncates packet
> too much"), there followed various other fixes for similar cases such
> as f4979fcea7fd ("rose: limit sk_filter trim to payload").
> 
> Latter introduced a new helper sk_filter_trim_cap(), where we can pass
> the trim limit directly to the socket filter handling. Make use of it
> here as well with sizeof(struct udphdr) as lower cap limit and drop the
> extra skb->len test in UDP's input path.
> 
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied.
