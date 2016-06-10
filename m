From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/mlx4_en: mlx4_en_netpoll() should
 schedule TX, not RX
Date: Thu, 09 Jun 2016 22:24:43 -0700 (PDT)
Message-ID: <20160609.222443.1427710681512363032.davem@davemloft.net>
References: <6320ccdc-d369-c08c-c959-6c8ed9b88d10@gmail.com>
	<1464267580.5939.83.camel@edumazet-glaptop3.roam.corp.google.com>
	<1464979969.5939.200.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ttoukan.linux@gmail.com, ebiederm@xmission.com, maze@google.com,
	edumazet@google.com, netdev@vger.kernel.org, willemb@google.com,
	eugenia@mellanox.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53710 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750871AbcFJFYp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 01:24:45 -0400
In-Reply-To: <1464979969.5939.200.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 03 Jun 2016 11:52:49 -0700

> From: Eric Dumazet <edumazet@google.com>
>=20
> I am not sure mlx4_en_netpoll() is doing anything useful right now.
>=20
> mlx4 has different NAPI structures for RX and TX, and netpoll only wa=
nts
> to drain TX queues.
>=20
> Lets schedule NAPI polls on TX, not RX.
>=20
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Maciej =AFenczykowski <maze@google.com>
> Cc: Eric W. Biederman <ebiederm@xmission.com>

Applied.
