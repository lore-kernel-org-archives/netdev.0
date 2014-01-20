From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: udp: check sk->sk_no_check when sending udpv6 packet
Date: Mon, 20 Jan 2014 04:54:53 +0100
Message-ID: <20140120035453.GA26622@order.stressinduktion.org>
References: <52DC9D25.9070809@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Duan Jiong <duanj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50618 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752430AbaATDyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:54:55 -0500
Content-Disposition: inline
In-Reply-To: <52DC9D25.9070809@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jan 20, 2014 at 11:51:01AM +0800, Duan Jiong wrote:
> 
> According to the user's intention, if SO_NO_CHECK option is
> set to true, the udpv6 packet should be out with no checksum.

Nak, UDP checksumming is mandatory when used with IPv6.

Greetings,

  Hannes
