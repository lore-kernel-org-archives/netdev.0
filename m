From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: ibmveth runtime errors
Date: Thu, 28 Apr 2011 13:46:03 -0700 (PDT)
Message-ID: <20110428.134603.15230365.davem@davemloft.net>
References: <20110427144901.4c3f79b3.sfr@canb.auug.org.au>
	<20110427103622.GA22781@rere.qmqm.pl>
	<20110428121124.39c036ff.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: mirq-linux@rere.qmqm.pl, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, santil@linux.vnet.ibm.com,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20110428121124.39c036ff.sfr@canb.auug.org.au>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 28 Apr 2011 12:11:24 +1000

> From: =3D?UTF-8?q?Micha=3DC5=3D82=3D20Miros=3DC5=3D82aw?=3D <mirq-lin=
ux@rere.qmqm.pl>
> Date: Thu, 28 Apr 2011 11:59:15 +1000
> Subject: [PATCH] net: ibmveth: force reconfiguring checksum settings =
on
>  startup
> MIME-Version: 1.0
> Content-Type: text/plain; charset=3DUTF-8
> Content-Transfer-Encoding: 8bit
>=20
> Commit b9367bf3ee6d ("net: ibmveth: convert to hw_features") accident=
ally
> removed call to ibmveth_set_csum_offload() in ibmveth_probe(). Put th=
e
> call back where it was, but with additional error checking provided
> by ibmveth_set_features().
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> Reported-by: Stephen Rothwell <sfr@canb.auug.org.au>
> [sfr: dev -> netdev]
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>

Applied, thanks everyone.
