From: Corentin Labbe <clabbe.montjoie@gmail.com>
Subject: [PATCH 1/3] Documentation: bindings: Add documentation for
 phy-is-integrated
Date: Thu, 10 Aug 2017 10:51:27 +0200
Message-ID: <20170810085129.20463-2-clabbe.montjoie@gmail.com>
References: <20170810085129.20463-1-clabbe.montjoie@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Corentin Labbe <clabbe.montjoie@gmail.com>,
 linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
 devicetree@vger.kernel.org
To: robh+dt@kernel.org, mark.rutland@arm.com, linux@armlinux.org.uk,
 maxime.ripard@free-electrons.com, wens@csie.org, peppe.cavallaro@st.com,
 alexandre.torgue@st.com, andrew@lunn.ch, f.fainelli@gmail.com
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <20170810085129.20463-1-clabbe.montjoie@gmail.com>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This patch adds documentation for phy-is-integrated, a boolean property
for PHY which permit to know if the PHY is integrated in the SoC.

For example, Allwinner H3 embeds an internal PHY but still permit to
connect an external PHY.
Since it is possible in theory to have the same PHY model both internal
and external, the only way to detect the location of the PHY is via this property.

Signed-off-by: Corentin Labbe <clabbe.montjoie@gmail.com>
---
 Documentation/devicetree/bindings/net/phy.txt | 4 ++++
 1 file changed, 4 insertions(+)

diff --git a/Documentation/devicetree/bindings/net/phy.txt b/Documentation/devicetree/bindings/net/phy.txt
index b55857696fc3..6fabc14da432 100644
--- a/Documentation/devicetree/bindings/net/phy.txt
+++ b/Documentation/devicetree/bindings/net/phy.txt
@@ -52,6 +52,10 @@ Optional Properties:
   Mark the corresponding energy efficient ethernet mode as broken and
   request the ethernet to stop advertising it.
 
+- phy-is-integrated: If set, indicates that the PHY is integrated in the SoC
+  and so is not an external PHY. (Some SoC embeds a PHY and still provide
+  support for an optional external PHY)
+
 Example:
 
 ethernet-phy@0 {
-- 
2.13.0
