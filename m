From: =?ISO-8859-1?Q?Emilio_L=F3pez?= <emilio@elopez.com.ar>
Subject: Re: linux-next: build warning after merge of the final tree (net-next
 tree related)
Date: Wed, 22 May 2013 10:24:28 -0300
Message-ID: <519CC70C.30604@elopez.com.ar>
References: <20130522155537.3cc0ee6254775cc88cf2218f@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130522155537.3cc0ee6254775cc88cf2218f@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

El 22/05/13 02:55, Stephen Rothwell escribi=F3:
> Hi all,
>=20
> After merging the final tree, today's linux-next build (sparc32 defco=
nfig)
> produced this warning:
>=20
> drivers/net/ethernet/sun/sunbmac.c: In function 'bigmac_set_multicast=
':
> drivers/net/ethernet/sun/sunbmac.c:998:6: warning: unused variable 'i=
' [-Wunused-variable]
>=20
> Introduced by commit bfd428daaf61 ("net: ethernet: sun: initialize
> variables directly") from the net-next tree.
>=20

Thank you for notifying.

After a second look at the code, I see the apple and korina patch
counterparts also leave an extra i variable now; the dm9000 patch shoul=
d
be unaffected as it still uses i for other things.

@David, what would you like me to do? I can send another set of patches
fixing this, resend the full original series but fixed, or resend just
the affected patches.

Emilio
