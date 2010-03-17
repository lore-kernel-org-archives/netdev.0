From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [Regression] r8169: enable 64-bit DMA by default for PCI Express
 devices (v2)
Date: Wed, 17 Mar 2010 21:52:06 +0100
Message-ID: <20100317205206.GA2699@electric-eye.fr.zoreil.com>
References: <20100315150806.GA15354@Dublin.logfs.org>
 <20100315151041.GA15667@Dublin.logfs.org>
 <20100315.115748.13754030.davem@davemloft.net>
 <51f3faa71003151628g5edc4d7av8916ac76cb337bfe@mail.gmail.com>
 <20100316083501.GA3489@Dublin.logfs.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Robert Hancock <hancockrwd@gmail.com>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: =?utf-8?B?Su+/vXJu?= Engel <joern@dublin.logfs.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100316083501.GA3489@Dublin.logfs.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 16, 2010 at 09:35:01AM +0100, J=EF=BF=BDrn Engel wrote:
[...]
> I just noticed lspci is also unhappy.
>=20
> With patch in:
> Bikini:~# lspci -vv > lspci
> pcilib: sysfs_read_vpd: read failed: Connection timed out.
>
> With patch reverted:
> Bikini:~# lspci -vv > lspci2
> Bikini:~# diff -u lspci*
> --- lspci       2010-03-16 09:03:02.000000000 +0100
> +++ lspci2      2010-03-16 09:09:36.000000000 +0100
> @@ -246,7 +246,7 @@
>                 Vector table: BAR=3D4 offset=3D00000000
>                 PBA: BAR=3D4 offset=3D00000800
>         Capabilities: [cc] Vital Product Data
> -               Not readable
> +               Unknown small resource type 00, will not decode more.

Neither looks good.

Did lspci output look different with an older kernel ?

--=20
Ueimor
