From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] 6lowpan: IPv6 link local address
Date: Thu, 10 May 2012 23:38:59 -0400 (EDT)
Message-ID: <20120510.233859.964333484372213068.davem@davemloft.net>
References: <1336656352-19518-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56778 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932408Ab2EKDjB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2012 23:39:01 -0400
In-Reply-To: <1336656352-19518-1-git-send-email-alex.bluesman.smirnov@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>
Date: Thu, 10 May 2012 17:25:52 +0400

> According to the RFC4944 (Transmission of IPv6 Packets over
> IEEE 802.15.4 Networks), chapter 7:
> 
> The IPv6 link-local address [RFC4291] for an IEEE 802.15.4 interface
> is formed by appending the Interface Identifier, as defined above, to
> the prefix FE80::/64.
> 
>   10 bits            54 bits                  64 bits
> +----------+-----------------------+----------------------------+
> |1111111010|         (zeros)       |    Interface Identifier    |
> +----------+-----------------------+----------------------------+
> 
> This patch adds IPv6 address generation support for the 6lowpan
> interfaces.
> 
> Signed-off-by: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>

Applied.
