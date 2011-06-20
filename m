From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] pxa168_eth: fix race in transmit path.
Date: Mon, 20 Jun 2011 17:49:17 +0200
Message-ID: <1308584957.26922.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <cover.1308555865.git.richard.cochran@omicron.at>
	 <180237f9f567de29068e51b1442629509bb03e43.1308555865.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	stable@kernel.org, Sachin Sanap <ssanap@marvell.com>,
	Zhangfei Gao <zgao6@marvell.com>,
	Philip Rakity <prakity@marvell.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:58348 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754364Ab1FTNtV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Jun 2011 09:49:21 -0400
Received: by wyb38 with SMTP id 38so1665891wyb.19
        for <netdev@vger.kernel.org>; Mon, 20 Jun 2011 06:49:20 -0700 (PDT)
In-Reply-To: <180237f9f567de29068e51b1442629509bb03e43.1308555865.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 20 juin 2011 =C3=A0 09:48 +0200, Richard Cochran a =C3=A9crit =
:
> Because the socket buffer is freed in the completion interrupt, it is=
 not
> safe to access it after submitting it to the hardware.
>=20
> Cc: stable@kernel.org
> Cc: Sachin Sanap <ssanap@marvell.com>
> Cc: Zhangfei Gao <zgao6@marvell.com>
> Cc: Philip Rakity <prakity@marvell.com>
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


