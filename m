From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next-2.6 4/6] ethtool: Fill out and update comment
 for struct ethtool_ops
Date: Sun, 03 Apr 2011 22:36:06 +0100
Message-ID: <1301866566.2935.50.camel@localhost>
References: <1301859889.2935.23.camel@localhost>
	 <1301860351.2935.27.camel@localhost>
	 <BANLkTik-+yCyrdSKhirfUSw7ecr0rg=PFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-net-drivers@solarflare.com
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:15820 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750936Ab1DCVgL convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Apr 2011 17:36:11 -0400
In-Reply-To: <BANLkTik-+yCyrdSKhirfUSw7ecr0rg=PFA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2011-04-03 at 23:25 +0200, Micha=C5=82 Miros=C5=82aw wrote:
> 2011/4/3 Ben Hutchings <bhutchings@solarflare.com>:
> > Briefly document all operations (except get_rx_ntuple), including
> > whether they may return an error code and whether they are deprecat=
ed.
> > Also mention some things that should be handled by the ethtool core
> > rather than by drivers.
> [...]
> > + * @set_pauseparam: Set pause parameters.  Returns a negative erro=
r code
> > + *     or zero.
> > + * @get_rx_csum: Deprecated in favour of the netdev feature %NETIF=
_F_RXCSUM.
> > + *     Report whether receive checksums are turned on or off.
> > + * @set_rx_csum: Deprecated in favour of the netdev op ndo_set_fla=
gs.  Turn
> > + *     receive checksum on or off.  Returns a negative error code =
or zero.
>=20
> Correct op is ndo_set_features and not ndo_set_flags.

That's what I meant.

> This should also
> refer to hw_features field as that's more likely to be the thing
> needed as the replacement.

Agreed.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

