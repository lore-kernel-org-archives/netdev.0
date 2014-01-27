From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: [PATCH 2/2] DT: net: davinci_emac: "ti,davinci-no-bd-ram" property is actually optional
Date: Tue, 28 Jan 2014 02:49:39 +0300
Message-ID: <201401280249.40451.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-doc@vger.kernel.org,
	davinci-linux-open-source@linux.davincidsp.com
To: netdev@vger.kernel.org, robh+dt@kernel.org, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, rob@landley.net, devicetree@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The "ti,davinci-no-bd-ram" property for the DaVinci EMAC binding simply can't be
required one, as it's boolean (which means it's absent if false).

While at it, document the property better...

Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

---
 Documentation/devicetree/bindings/net/davinci_emac.txt |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

Index: net/Documentation/devicetree/bindings/net/davinci_emac.txt
===================================================================
--- net.orig/Documentation/devicetree/bindings/net/davinci_emac.txt
+++ net/Documentation/devicetree/bindings/net/davinci_emac.txt
@@ -10,7 +10,6 @@ Required properties:
 - ti,davinci-ctrl-mod-reg-offset: offset to control module register
 - ti,davinci-ctrl-ram-offset: offset to control module ram
 - ti,davinci-ctrl-ram-size: size of control module ram
-- ti,davinci-no-bd-ram: has the emac controller BD RAM
 - interrupts: interrupt mapping for the davinci emac interrupts sources:
               4 sources: <Receive Threshold Interrupt
 			  Receive Interrupt
@@ -22,6 +21,7 @@ Optional properties:
               If absent, davinci_emac driver defaults to 100/FULL.
 - local-mac-address : 6 bytes, mac address
 - ti,davinci-rmii-en: 1 byte, 1 means use RMII
+- ti,davinci-no-bd-ram: boolean, does EMAC has BD RAM?
 
 Example (enbw_cmc board):
 	eth0: emac@1e20000 {
