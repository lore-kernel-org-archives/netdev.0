From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH][SOCK]: shrink struct sock
Date: Fri, 04 May 2007 08:10:15 +0200
Message-ID: <463ACE47.6080807@cosmosbay.com>
References: <20070504041101.GA27519@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:58065 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528AbXEDGK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2007 02:10:28 -0400
In-Reply-To: <20070504041101.GA27519@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Arnaldo Carvalho de Melo a =E9crit :
>=20
> [acme@mica linux-2.6]$ pahole -C sk_buff_head net/core/sock.o
> struct sk_buff_head {
> 	struct sk_buff *           next;                 /*     0     8 */
> 	struct sk_buff *           prev;                 /*     8     8 */
> 	__u32                      qlen;                 /*    16     4 */
> 	spinlock_t                 lock;                 /*    20     8 */
> }; /* size: 32, cachelines: 1 */
>    /* padding: 4 */
>    /* last cacheline: 32 bytes */


Hum, maybe not enough tea this morning, but I always thought spinlock_t=
 size=20
was 4 bytes....

