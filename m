From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: linux-next: manual merge of the net-next tree with the arm-soc tree
Date: Tue, 21 Jun 2016 10:56:21 +0200
Message-ID: <4384645.F021K1OoaK@wuerfel>
References: <20160621111839.34936836@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Olof Johansson <olof@lixom.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Pramod Kumar <pramod.kumar@broadcom.com>,
	linux-kernel@vger.kernel.org,
	Yendapally Reddy Dhananjaya Reddy
	<yendapally.reddy@broadcom.com>, linux-next@vger.kernel.org,
	Jon Mason <jon.mason@broadcom.com>
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:63086 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751853AbcFUIyz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2016 04:54:55 -0400
In-Reply-To: <20160621111839.34936836@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday, June 21, 2016 11:18:39 AM CEST Stephen Rothwell wrote:
> Today's linux-next merge of the net-next tree got conflicts in:
> 
>   arch/arm64/boot/dts/broadcom/ns2-svk.dts
>   arch/arm64/boot/dts/broadcom/ns2.dtsi
> 
> between commits:
> 
>   97b1504a30b3 ("arm64: dts: enable pinctrl for Broadcom NS2 SoC")
>   5dcc9c7618df ("arm64: dts: NS2: Add CCI-400 PMU support")
> 
> from the arm-soc tree and commit:
> 
>   5f1a067bfa0a ("dt: mdio-mux: Add mdio multiplexer driver node")
> 
> from the net-next tree.
> 
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.

Looks good to me, thanks!

I don't see a good way to resolve the conflict before the merge window,
but it's simple enough that we can just send it this way and let
Linus handle it.

	Arnd
