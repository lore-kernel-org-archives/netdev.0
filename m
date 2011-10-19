From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 2/3] dp83640: use proper function to free transmit time
 stamping packets
Date: Wed, 19 Oct 2011 06:47:22 +0200
Message-ID: <1318999642.19139.20.camel@edumazet-laptop>
References: <cover.1318498805.git.richard.cochran@omicron.at>
	 <d4208d065cae9f825a750d6520e5f641f76b5e39.1318498805.git.richard.cochran@omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>, stable@kernel.org
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63898 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754387Ab1JSEr2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Oct 2011 00:47:28 -0400
Received: by wyg36 with SMTP id 36so1308223wyg.19
        for <netdev@vger.kernel.org>; Tue, 18 Oct 2011 21:47:27 -0700 (PDT)
In-Reply-To: <d4208d065cae9f825a750d6520e5f641f76b5e39.1318498805.git.richard.cochran@omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 13 octobre 2011 =C3=A0 11:46 +0200, Richard Cochran a =C3=A9cr=
it :
> The previous commit enforces a new rule for handling the cloned packe=
ts
> for transmit time stamping. These packets must not be freed using any=
 other
> function than skb_complete_tx_timestamp. This commit fixes the one an=
d only
> driver using this API.
>=20
> The driver first appeared in v3.0.
>=20
> Signed-off-by: Richard Cochran <richard.cochran@omicron.at>
> Cc: <stable@kernel.org>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>
