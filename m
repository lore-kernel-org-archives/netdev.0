From: =?ISO-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Subject: Re: [PATCH net-next-2.6 4/6] ethtool: Fill out and update comment for
 struct ethtool_ops
Date: Sun, 3 Apr 2011 23:25:23 +0200
Message-ID: <BANLkTik-+yCyrdSKhirfUSw7ecr0rg=PFA@mail.gmail.com>
References: <1301859889.2935.23.camel@localhost> <1301860351.2935.27.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f181.google.com ([209.85.216.181]:41793 "EHLO
	mail-qy0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750876Ab1DCVZo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 17:25:44 -0400
Received: by qyg14 with SMTP id 14so3454792qyg.19
        for <netdev@vger.kernel.org>; Sun, 03 Apr 2011 14:25:43 -0700 (PDT)
In-Reply-To: <1301860351.2935.27.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/4/3 Ben Hutchings <bhutchings@solarflare.com>:
> Briefly document all operations (except get_rx_ntuple), including
> whether they may return an error code and whether they are deprecated=
=2E
> Also mention some things that should be handled by the ethtool core
> rather than by drivers.
[...]
> + * @set_pauseparam: Set pause parameters. =C2=A0Returns a negative e=
rror code
> + * =C2=A0 =C2=A0 or zero.
> + * @get_rx_csum: Deprecated in favour of the netdev feature %NETIF_F=
_RXCSUM.
> + * =C2=A0 =C2=A0 Report whether receive checksums are turned on or o=
ff.
> + * @set_rx_csum: Deprecated in favour of the netdev op ndo_set_flags=
=2E =C2=A0Turn
> + * =C2=A0 =C2=A0 receive checksum on or off. =C2=A0Returns a negativ=
e error code or zero.

Correct op is ndo_set_features and not ndo_set_flags. This should also
refer to hw_features field as that's more likely to be the thing
needed as the replacement.

Best Regards,
Micha=C5=82 Miros=C5=82aw
