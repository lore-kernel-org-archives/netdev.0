From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] net: Reflect RX hash for transmit
Date: Sun, 15 Feb 2015 20:59:29 +0100
Message-ID: <54E0FAA1.7000900@iogearbox.net>
References: <1424025438-1659-1-git-send-email-therbert@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
To: Tom Herbert <therbert@google.com>, davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46773 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755332AbbBOT7f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 14:59:35 -0500
In-Reply-To: <1424025438-1659-1-git-send-email-therbert@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/15/2015 07:37 PM, Tom Herbert wrote:
> This patch allows a driver to request that the receive hash it provides
> to the stack is reflected back in skb->hash for packets transmitted
> on the associated connection.
[...]
> +	if (unlikely(skb->reflect_hash && sk->sk_txhash != skb->hash))
> +		sk->sk_txhash = skb->hash;

Is there also an initial user setting this somewhere?
