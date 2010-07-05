From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] netfilter: postpone the checksum calculation
Date: Mon, 05 Jul 2010 10:39:42 +0200
Message-ID: <4C319A4E.5080507@trash.net>
References: <1278050577-3358-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:39724 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753042Ab0GEIjm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Jul 2010 04:39:42 -0400
In-Reply-To: <1278050577-3358-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao wrote:
> netfilter: postpone the checksum calculation.
>
> postpone the checksum calculation, then if the output NIC supports checksum
> offloading, we can utlize it. And though the output NIC doesn't support
> checksum offloading, but we'll mangle this packet, this can free us from
> updating the checksum, as the checksum calculation occurs later.

Applied, thanks.
