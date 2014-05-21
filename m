From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: cdc_ncm: fix 64bit division build error
Date: Wed, 21 May 2014 01:56:56 -0400 (EDT)
Message-ID: <20140521.015656.1427912008346226331.davem@davemloft.net>
References: <1400484069-13702-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	alexey.orishko@gmail.com, oliver@neukum.org, mrkiko.rs@gmail.com,
	David.Laight@ACULAB.COM, sfr@canb.auug.org.au
To: bjorn@mork.no
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46042 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751967AbaEUF5H convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2014 01:57:07 -0400
In-Reply-To: <1400484069-13702-1-git-send-email-bjorn@mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Bj=F8rn Mork <bjorn@mork.no>
Date: Mon, 19 May 2014 09:21:09 +0200

> The upper timer_interval limit is arbitrary and much higher
> than anything usable in the real world.  Reducing it from 15s
> to ~4s to make the timer_interval fit in an u32 does not make
> much difference.  The limit is still outside the practical
> bounds.
>=20
> This eliminates the need for a 64bit timer_interval, fixing a
> build error related to 64bit division:
>=20
>  drivers/built-in.o: In function `cdc_ncm_get_coalesce':
>  ak8975.c:(.text+0x1ac994): undefined reference to `__aeabi_uldivmod'
>=20
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> Signed-off-by: Bj=F8rn Mork <bjorn@mork.no>

Applied, thank you.
