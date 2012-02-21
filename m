From: Toralf =?utf-8?q?F=C3=B6rster?= <toralf.foerster@gmx.de>
Subject: Kconfig: unmet direct dependencies in 3.3-rc4
Date: Tue, 21 Feb 2012 22:21:26 +0100
Message-ID: <201202212221.27202.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, netfilter@vger.kernel.org,
	dri-devel@lists.freedesktop.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

running a few "make randconfigs" gave warnings (seen below) for the cur=
rent=20
git kernel tree. Are there already patches in -next for all ?


warning: (HAVE_TEXT_POKE_SMP) selects STOP_MACHINE which has unmet dire=
ct=20
dependencies (SMP && MODULE_UNLOAD ||=20
HOTPLUG_CPU)


warning: (DRM_RADEON_KMS && DRM_I915 && STUB_POULSBO && FB_BACKLIGHT &&=
=20
USB_APPLEDISPLAY && FB_OLPC_DCON &&=20
ASUS_LAPTOP && SONY_LAPTOP && THINKPAD_ACPI && EEEPC_LAPTOP && ACPI_ASU=
S &&=20
ACPI_CMPC && SAMSUNG_Q10) selects=20
BACKLIGHT_CLASS_DEVICE which has unmet direct dependencies (HAS_IOMEM &=
&=20
BACKLIGHT_LCD_SUPPORT)


warning: (WIMAX_IWMC3200_SDIO) selects IWMC3200TOP which has unmet dire=
ct=20
dependencies (MMC && EXPERIMENTAL)


warning: (BRIDGE_NF_EBTABLES) selects NETFILTER_XTABLES which has unmet=
 direct=20
dependencies (NET && INET && NETFILTER)



--=20
MfG/Sincerely
Toralf F=C3=B6rster
pgp finger print: 7B1A 07F4 EC82 0F90 D4C2 8936 872A E508 7DB6 9DA3
