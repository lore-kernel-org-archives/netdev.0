From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] sock: fix possible NULL sk dereference in
 __skb_tstamp_tx
Date: Thu, 12 Mar 2015 00:11:30 -0400 (EDT)
Message-ID: <20150312.001130.1103295848602582907.davem@davemloft.net>
References: <1426103035-24748-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gnomes@lxorguk.ukuu.org.uk
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56233 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750725AbbCLELd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2015 00:11:33 -0400
In-Reply-To: <1426103035-24748-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Wed, 11 Mar 2015 15:43:55 -0400

> From: Willem de Bruijn <willemb@google.com>
> 
> Test that sk != NULL before reading sk->sk_tsflags.
> 
> Fixes: 49ca0d8bfaf3 ("net-timestamp: no-payload option")
> 
> Reported-by: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks Willem.
