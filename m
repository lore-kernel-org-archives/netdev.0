From: "Arun KS" <getarunks@gmail.com>
Subject: [PATCH 1/1]smc911x Modify driver to also work with omap24xx
Date: Mon, 30 Jun 2008 21:31:19 +0530
Message-ID: <dfeb90390806300901i57d52dd9l80f0831d9881d00b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
	boundary="----=_Part_13472_13993971.1214841679298"
Cc: linux-omap@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ti-out-0910.google.com ([209.85.142.187]:34612 "EHLO
	ti-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752031AbYF3QBV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jun 2008 12:01:21 -0400
Received: by ti-out-0910.google.com with SMTP id b6so806699tic.23
        for <netdev@vger.kernel.org>; Mon, 30 Jun 2008 09:01:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

------=_Part_13472_13993971.1214841679298
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

net:smc911x Modify driver to also work with omap24xx

Signed-off-by: Arun KS <arunks@mistralsolutions.com>
---
 drivers/net/Kconfig   |    2 +-
 drivers/net/smc911x.h |    5 +++++
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/Kconfig b/drivers/net/Kconfig
index 61ecee7..ecda0b6 100644
--- a/drivers/net/Kconfig
+++ b/drivers/net/Kconfig
@@ -955,7 +955,7 @@ config SMC911X
 	tristate "SMSC LAN911[5678] support"
 	select CRC32
 	select MII
-	depends on ARCH_PXA || SH_MAGIC_PANEL_R2 || ARCH_OMAP34XX
+	depends on ARCH_PXA || SH_MAGIC_PANEL_R2 || ARCH_OMAP24XX || ARCH_OMAP34XX
 	help
 	  This is a driver for SMSC's LAN911x series of Ethernet chipsets
 	  including the new LAN9115, LAN9116, LAN9117, and LAN9118.
diff --git a/drivers/net/smc911x.h b/drivers/net/smc911x.h
index dad93a8..0f406a0 100644
--- a/drivers/net/smc911x.h
+++ b/drivers/net/smc911x.h
@@ -47,6 +47,11 @@
   #define SMC_USE_32BIT		1
   #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
   #define SMC_MEM_RESERVED	1
+#elif defined(CONFIG_ARCH_OMAP24XX)
+  #define SMC_USE_16BIT		0
+  #define SMC_USE_32BIT		1
+  #define SMC_IRQ_SENSE		IRQF_TRIGGER_LOW
+  #define SMC_MEM_RESERVED	1
 #endif


-- 
1.5.3.4

------=_Part_13472_13993971.1214841679298
Content-Type: text/x-patch;
 name=0002-net-smc911x-Modify-driver-to-also-work-with-omap24xx.patch
Content-Transfer-Encoding: base64
X-Attachment-Id: f_fi3825yz0
Content-Disposition: attachment;
 filename=0002-net-smc911x-Modify-driver-to-also-work-with-omap24xx.patch

RnJvbSAxODBiMGJjZDE5ZTM1YzExNTEyNjk3ZjNiNTFmZjkwMmNiNWU5MGUyIE1vbiBTZXAgMTcg
MDA6MDA6MDAgMjAwMQpGcm9tOiBBcnVuIEtTIDxhcnVua3NAbWlzdHJhbHNvbHV0aW9ucy5jb20+
CkRhdGU6IE1vbiwgMzAgSnVuIDIwMDggMTk6MjQ6MjcgKzA1MzAKU3ViamVjdDogW1BBVENIXSBu
ZXQ6c21jOTExeCBNb2RpZnkgZHJpdmVyIHRvIGFsc28gd29yayB3aXRoIG9tYXAyNHh4CgpuZXQ6
c21jOTExeCBNb2RpZnkgZHJpdmVyIHRvIGFsc28gd29yayB3aXRoIG9tYXAyNHh4CgpTaWduZWQt
b2ZmLWJ5OiBBcnVuIEtTIDxhcnVua3NAbWlzdHJhbHNvbHV0aW9ucy5jb20+Ci0tLQogZHJpdmVy
cy9uZXQvS2NvbmZpZyAgIHwgICAgMiArLQogZHJpdmVycy9uZXQvc21jOTExeC5oIHwgICAgNSAr
KysrKwogMiBmaWxlcyBjaGFuZ2VkLCA2IGluc2VydGlvbnMoKyksIDEgZGVsZXRpb25zKC0pCgpk
aWZmIC0tZ2l0IGEvZHJpdmVycy9uZXQvS2NvbmZpZyBiL2RyaXZlcnMvbmV0L0tjb25maWcKaW5k
ZXggNjFlY2VlNy4uZWNkYTBiNiAxMDA2NDQKLS0tIGEvZHJpdmVycy9uZXQvS2NvbmZpZworKysg
Yi9kcml2ZXJzL25ldC9LY29uZmlnCkBAIC05NTUsNyArOTU1LDcgQEAgY29uZmlnIFNNQzkxMVgK
IAl0cmlzdGF0ZSAiU01TQyBMQU45MTFbNTY3OF0gc3VwcG9ydCIKIAlzZWxlY3QgQ1JDMzIKIAlz
ZWxlY3QgTUlJCi0JZGVwZW5kcyBvbiBBUkNIX1BYQSB8fCBTSF9NQUdJQ19QQU5FTF9SMiB8fCBB
UkNIX09NQVAzNFhYCisJZGVwZW5kcyBvbiBBUkNIX1BYQSB8fCBTSF9NQUdJQ19QQU5FTF9SMiB8
fCBBUkNIX09NQVAyNFhYIHx8IEFSQ0hfT01BUDM0WFggCiAJaGVscAogCSAgVGhpcyBpcyBhIGRy
aXZlciBmb3IgU01TQydzIExBTjkxMXggc2VyaWVzIG9mIEV0aGVybmV0IGNoaXBzZXRzCiAJICBp
bmNsdWRpbmcgdGhlIG5ldyBMQU45MTE1LCBMQU45MTE2LCBMQU45MTE3LCBhbmQgTEFOOTExOC4K
ZGlmZiAtLWdpdCBhL2RyaXZlcnMvbmV0L3NtYzkxMXguaCBiL2RyaXZlcnMvbmV0L3NtYzkxMXgu
aAppbmRleCBkYWQ5M2E4Li4wZjQwNmEwIDEwMDY0NAotLS0gYS9kcml2ZXJzL25ldC9zbWM5MTF4
LmgKKysrIGIvZHJpdmVycy9uZXQvc21jOTExeC5oCkBAIC00Nyw2ICs0NywxMSBAQAogICAjZGVm
aW5lIFNNQ19VU0VfMzJCSVQJCTEKICAgI2RlZmluZSBTTUNfSVJRX1NFTlNFCQlJUlFGX1RSSUdH
RVJfTE9XCiAgICNkZWZpbmUgU01DX01FTV9SRVNFUlZFRAkxCisjZWxpZiBkZWZpbmVkKENPTkZJ
R19BUkNIX09NQVAyNFhYKQorICAjZGVmaW5lIFNNQ19VU0VfMTZCSVQJCTAKKyAgI2RlZmluZSBT
TUNfVVNFXzMyQklUCQkxCisgICNkZWZpbmUgU01DX0lSUV9TRU5TRQkJSVJRRl9UUklHR0VSX0xP
VworICAjZGVmaW5lIFNNQ19NRU1fUkVTRVJWRUQJMQogI2VuZGlmCiAKIAotLSAKMS41LjMuNAoK

------=_Part_13472_13993971.1214841679298--
