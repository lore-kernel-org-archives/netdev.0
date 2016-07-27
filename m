From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net-next tree with the arm-soc tree
Date: Wed, 27 Jul 2016 12:53:42 +1000
Message-ID: <20160727125342.1902ece1@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Bjorn Helgaas <bhelgaas@google.com>, Duc Dang <dhdang@apm.com>,
	Iyappan Subramanian <isubramanian@apm.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>,
	Olof Johansson <olof@lixom.net>, Arnd Bergmann <arnd@arndb.de>,
	<linux-arm-kernel@lists.infradead.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net-next tree got a conflict in:

  arch/arm64/boot/dts/apm/apm-shadowcat.dtsi

between commit:

  cafc4cd0c8b8 ("arm64: dts: apm: Use lowercase consistently for hex constants")

from the arm-soc tree and commit:

  8e694cd2762c ("dtb: xgene: Add MDIO node")

from the net-next tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
index 21028b145d91,2e1e5daa1dc7..000000000000
--- a/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
+++ b/arch/arm64/boot/dts/apm/apm-shadowcat.dtsi
@@@ -628,9 -636,9 +636,9 @@@
  		sgenet0: ethernet@1f610000 {
  			compatible = "apm,xgene2-sgenet";
  			status = "disabled";
- 			reg = <0x0 0x1f610000 0x0 0x10000>,
+ 			reg = <0x0 0x1f610000 0x0 0xd100>,
 -			      <0x0 0x1f600000 0x0 0Xd100>,
 -			      <0x0 0x20000000 0x0 0X20000>;
 +			      <0x0 0x1f600000 0x0 0xd100>,
 +			      <0x0 0x20000000 0x0 0x20000>;
  			interrupts = <0 96 4>,
  				     <0 97 4>;
  			dma-coherent;
