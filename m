From: David Miller <davem@davemloft.net>
Subject: Re: Bug in computing data_len in tcp_sendmsg?
Date: Wed, 30 Nov 2011 23:16:59 -0500 (EST)
Message-ID: <20111130.231659.1153505739102359807.davem@davemloft.net>
References: <CA+mtBx8+sajFaCWqHRr+pY5EAHwN8G61v6cr-HydYhbbdxAgHQ@mail.gmail.com>
	<1322710962.2577.3.camel@edumazet-laptop>
	<CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:58278 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647Ab1LAERC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 23:17:02 -0500
In-Reply-To: <CA+mtBx_CUsuGunKONwBNA8qyVni16+RtrRL8w=THYY0mEDcvaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 30 Nov 2011 20:06:09 -0800

> Actually, I think I am misinterpreting the meaning of data_len, looks
> like it is intended to return the number of bytes in the page buffer
> area

skb->len is all bytes, skb->data_len covers only segmented portion.

> (comment on the function would be have been nice ;-) ).

Patches welcome, otherwise:

http://vger.kernel.org/~davem/skb.html
