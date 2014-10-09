From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: Upstream build failure due to commit d43a396af0 ('net: fs_enet:
 Add NAPI TX')
Date: Thu, 9 Oct 2014 10:51:13 -0700
Message-ID: <20141009175113.GA4461@roeck-us.net>
References: <20141009165122.GA1964@roeck-us.net>
 <5436C912.5040705@c-s.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Pantelis Antoniou <pantelis.antoniou@gmail.com>,
	Vitaly Bordug <vbordug@ru.mvista.com>, netdev@vger.kernel.org
To: christophe leroy <christophe.leroy@c-s.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f175.google.com ([209.85.192.175]:47715 "EHLO
	mail-pd0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927AbaJIRvT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Oct 2014 13:51:19 -0400
Content-Disposition: inline
In-Reply-To: <5436C912.5040705@c-s.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 09, 2014 at 07:42:42PM +0200, christophe leroy wrote:
>=20
> Le 09/10/2014 18:51, Guenter Roeck a =E9crit :
> >Hi,
> >
> >I see the following build failure in upstream Linux.
> >
> >drivers/net/ethernet/freescale/fs_enet/mac-scc.c:119:32: error: 'SCC=
E_ENET_TXF' undeclared
> >
> >This is not surprising as SCCE_ENET_TXF is not defined anywhere in t=
he kernel.
> >linux-next fails to build with the same error.
> >
> >Affected builds are
> >	powerpc:mpc85xx_defconfig
> >	powerpc:mpc85xx_smp_defconfig
> >	powerpc:tqm8xx_defconfig
> >
> >Can you please have a look ?
> >
> >
> Yes, fixed by the patch below submitted this afternoon.
>=20
Excellent, thanks!

Guenter
