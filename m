From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH] hamachi: Delete TX checksumming code commented out since 1999
Date: Sat, 7 May 2011 09:59:28 +0200
Message-ID: <BANLkTi=ZeY6X1XOdK2UXsODNBqzbbG+4KQ@mail.gmail.com>
References: <20110506.115945.104066424.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:35020 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348Ab1EGH7u convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 May 2011 03:59:50 -0400
Received: by qwk3 with SMTP id 3so2328830qwk.19
        for <netdev@vger.kernel.org>; Sat, 07 May 2011 00:59:49 -0700 (PDT)
In-Reply-To: <20110506.115945.104066424.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/5/6 David Miller <davem@davemloft.net>:
>
> TX checksumming support has been ifdef commented out of this driver
> for more than 10 years, and it makes references to aspects of the IPv=
4
> stack from back then as well.
>
> If someone has one of these rare cards and wants to properly resurrec=
t
> TX checksumming support, they can still get at this code in the
> version control history.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> I stumbled over this cruft while auditing ip_queue_xmit() users.
>
> =A0drivers/net/hamachi.c | =A0 79 -----------------------------------=
--------------
> =A01 files changed, 0 insertions(+), 79 deletions(-)
>
> diff --git a/drivers/net/hamachi.c b/drivers/net/hamachi.c
> index 80d25ed..f5fba73 100644
> --- a/drivers/net/hamachi.c
> +++ b/drivers/net/hamachi.c
> @@ -132,14 +132,8 @@ static int tx_params[MAX_UNITS] =3D {-1, -1, -1,=
 -1, -1, -1, -1, -1};
> =A0/*
> =A0* RX_CHECKSUM turns on card-generated receive checksum generation =
for
> =A0* =A0 TCP and UDP packets. =A0Otherwise the upper layers do the ca=
lculation.
> - * TX_CHECKSUM won't do anything too useful, even if it works. =A0Th=
ere's no
> - * =A0 easy mechanism by which to tell the TCP/UDP stack that it nee=
d not
> - * =A0 generate checksums for this device. =A0But if somebody can fi=
nd a way
> - * =A0 to get that to work, most of the card work is in here already=
=2E
> =A0* 3/10/1999 Pete Wyckoff <wyckoff@ca.sandia.gov>
> =A0*/
> -#undef =A0TX_CHECKSUM
> -#define RX_CHECKSUM

This also disables RX checksumming. You wanted to leave '#define
RX_CHECKSUM' in place?

Best Regards,
Micha=B3 Miros=B3aw
