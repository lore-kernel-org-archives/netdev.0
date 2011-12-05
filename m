From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 3/4] caif: Add support for flow-control on
 device's tx-queue
Date: Mon, 05 Dec 2011 18:46:19 -0500 (EST)
Message-ID: <20111205.184619.2049555377796266031.davem@davemloft.net>
References: <1323033775-3496-1-git-send-email-sjur.brandeland@stericsson.com>
	<1323033775-3496-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, alexey.orishko@stericsson.com,
	eric.dumazet@gmail.com
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:51553 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932481Ab1LEXqZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Dec 2011 18:46:25 -0500
In-Reply-To: <1323033775-3496-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>
Date: Sun,  4 Dec 2011 22:22:54 +0100

> Flow control is implemented by inspecting the qdisc queue length
> in order to detect potential overflow on the TX queue. When a thresho=
ld
> is reached flow-off is sent upwards in the CAIF stack. At the same ti=
me
> the skb->destructor is hi-jacked by orphaning the SKB and the origina=
l
> destructor is replaced with a "flow-on" callback. When the "hi-jacked=
"
> SKB is consumed the queue should be empty, and the "flow-on" callback
> is called and xon is sent upwards in the CAIF stack.
>=20
> Signed-off-by: Sjur Br=E6ndeland <sjur.brandeland@stericsson.com>

Applied.
