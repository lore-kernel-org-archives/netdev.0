From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] pxa168_eth: fix race in transmit path.
Date: Mon, 20 Jun 2011 14:02:25 -0700 (PDT)
Message-ID: <20110620.140225.1201667930841253539.davem@davemloft.net>
References: <cover.1308555865.git.richard.cochran@omicron.at>
	<180237f9f567de29068e51b1442629509bb03e43.1308555865.git.richard.cochran@omicron.at>
	<1308584957.26922.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: richardcochran@gmail.com, netdev@vger.kernel.org,
	stable@kernel.org, ssanap@marvell.com, zgao6@marvell.com,
	prakity@marvell.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33084 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755687Ab1FTVCc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 17:02:32 -0400
In-Reply-To: <1308584957.26922.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 20 Jun 2011 17:49:17 +0200

> Le lundi 20 juin 2011 =E0 09:48 +0200, Richard Cochran a =E9crit :
>> Because the socket buffer is freed in the completion interrupt, it i=
s not
>> safe to access it after submitting it to the hardware.
>>=20
>> Cc: stable@kernel.org
>> Cc: Sachin Sanap <ssanap@marvell.com>
>> Cc: Zhangfei Gao <zgao6@marvell.com>
>> Cc: Philip Rakity <prakity@marvell.com>
>> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
