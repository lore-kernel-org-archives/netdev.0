From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the devicetree tree with the net-next
 tree
Date: Fri, 23 Jun 2017 13:37:58 +1000
Message-ID: <20170623133758.39e26d71@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux-Next Mailing List <linux-next@vger.kernel.org>,
        Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
        Russell King <rmk+kernel@armlinux.org.uk>,
        Frank Rowand <frank.rowand@sony.com>
To: Rob Herring <robherring2@gmail.com>,
        David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Rob,

Today's linux-next merge of the devicetree tree got a conflict in:

  Documentation/devicetree/bindings/net/ethernet.txt

between commit:

  c125ca091873 ("net: phy: add XAUI and 10GBASE-KR PHY connection types")

from the net-next tree and commit:

  076fb0c4b6e1 ("of: update ePAPR references to point to Devicetree Specification")

from the devicetree tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc Documentation/devicetree/bindings/net/ethernet.txt
index d4abe9a98109,08dd263beeb9..000000000000
--- a/Documentation/devicetree/bindings/net/ethernet.txt
+++ b/Documentation/devicetree/bindings/net/ethernet.txt
@@@ -32,11 -33,11 +33,13 @@@ The following properties are common to 
    * "2000base-x",
    * "2500base-x",
    * "rxaui"
 +  * "xaui"
 +  * "10gbase-kr" (10GBASE-KR, XFI, SFI)
- - phy-connection-type: the same as "phy-mode" property but described in ePAPR;
+ - phy-connection-type: the same as "phy-mode" property but described in the
+   Devicetree Specification;
  - phy-handle: phandle, specifies a reference to a node representing a PHY
-   device; this property is described in ePAPR and so preferred;
+   device; this property is described in the Devicetree Specification and so
+   preferred;
  - phy: the same as "phy-handle" property, not recommended for new bindings.
  - phy-device: the same as "phy-handle" property, not recommended for new
    bindings.
