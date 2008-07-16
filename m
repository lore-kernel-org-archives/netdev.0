From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: sendfile() broken with 2.6.26 + Apache 2 ?
Date: Wed, 16 Jul 2008 07:38:02 +0200
Message-ID: <487D893A.5080207@cosmosbay.com>
References: <487CD7A7.2080800@jeffray.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Ian Jeffray <ian@jeffray.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604003av.neufgp.fr ([84.96.92.124]:58006
	"EHLO neuf-infra-smtp-out-sp604003av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751133AbYGPFns convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 01:43:48 -0400
In-Reply-To: <487CD7A7.2080800@jeffray.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

CC to netdev where this report might find better answers

Ian Jeffray a =E9crit :
> All,
>=20
> I moved from kernel 2.6.25.4 to 2.6.26 yesterday and observed that
> large files sent via Apache2 are partially corrupt.
>=20
> This appears to be linked to sendfile() -- disabling the use of
> sendfile in the apache config (EnableSendfile Off) allows it to
> function as normal.
>=20
> My system is a simple Core2Duo running Debian lenny/sid; nothing
> special, and I have never observed problems like this before.
>=20
> The problem feels certainly related to sendfile() since the data
> reads correctly from disc in other programs, and via CIFS etc.
>=20
> The corruption happens part-way in to the file... I've no exact
> figure but it would seem like maybe 32KB -- I'm seeing broken
> PNGs served from Apache, where the top few dozen lines decode
> correctly, and the rest is garbage.
>=20
> I've made basically no configuration changes between 2.6.25.4 and
> 2.6.26 and have explicitly tried both enabling and disabling the
> new PAT support to no effect.
>=20
> This is completely repeatable and reproducible.
>=20
> Is anyone else seeing this broken behaviour?
>=20


What kind of network adapter are you using ? (lspci | grep -i ether)

If you disable TCP segmentation offload on this NIC (ethtool -K eth0 ts=
o off) , is this problem still present ?




