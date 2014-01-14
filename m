From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 3/7] staging,spear_adc: Add dependency on HAS_IOMEM
Date: Tue, 14 Jan 2014 16:45:41 +0100
Message-ID: <1389714345-20165-3-git-send-email-richard@nod.at>
References: <1389714345-20165-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sebastian.hesselbarth@gmail.com, florian@openwrt.org,
	thomas.petazzoni@free-electrons.com, lars@metafoo.de,
	marex@denx.de, acourbot@nvidia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, devel@driverdev.osuosl.org,
	linux-iio@vger.kernel.org, Richard Weinberger <richard@nod.at>
To: kishon@ti.com, anton@enomsg.org, dwmw2@infradead.org,
	richardcochran@gmail.com, lidza.louina@gmail.com,
	gregkh@linuxfoundation.org, jic23@kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.ns.miles-group.at ([95.130.255.144]:1666 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751805AbaANPqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 14 Jan 2014 10:46:15 -0500
In-Reply-To: <1389714345-20165-1-git-send-email-richard@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On archs like S390 or um this driver cannot build nor work.
Make it depend on HAS_IOMEM to bypass build failures.

drivers/staging/iio/adc/spear_adc.c: In function =E2=80=98spear_adc_pro=
be=E2=80=99:
drivers/staging/iio/adc/spear_adc.c:393:2: error: implicit declaration =
of function =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-decl=
aration

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 drivers/staging/iio/adc/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/staging/iio/adc/Kconfig b/drivers/staging/iio/adc/=
Kconfig
index e3d6430..7d5d675 100644
--- a/drivers/staging/iio/adc/Kconfig
+++ b/drivers/staging/iio/adc/Kconfig
@@ -128,6 +128,7 @@ config MXS_LRADC
 config SPEAR_ADC
 	tristate "ST SPEAr ADC"
 	depends on PLAT_SPEAR || COMPILE_TEST
+	depends on HAS_IOMEM
 	help
 	  Say yes here to build support for the integrated ADC inside the
 	  ST SPEAr SoC. Provides direct access via sysfs.
--=20
1.8.1.4
