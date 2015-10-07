From: Geert Uytterhoeven <geert+renesas@glider.be>
Subject: [PATCH v2 0/4] sh_eth: Remove obsolete platform_device_id entries
Date: Wed,  7 Oct 2015 10:14:13 +0200
Message-ID: <1444205657-25314-1-git-send-email-geert+renesas@glider.be>
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org,
	Geert Uytterhoeven <geert+renesas@glider.be>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [195.130.137.88] ([195.130.137.88]:39157 "EHLO
	michel.telenet-ops.be" rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org
	with ESMTP id S1752252AbbJGKWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 06:22:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

    Hi David,

Since commit 3d7608e4c169af03 ("ARM: shmobile: bockw: remove legacy
board file and config"), which is now in arm-soc/for-next, shmobile SoCs
are only supported in generic DT-only ARM multi-platform builds.
The sh_eth driver doesn't need to match platform devices by name
anymore, hence this series removes the corresponding platform_device_id
entries.

Changes since v1:
  - Protect some data and functions by #ifdef CONFIG_OF to silence
    unused compiler warnings on SH,
  - New patches 3 and 4.

Thanks!

Geert Uytterhoeven (4):
  sh_eth: Remove obsolete r7s72100-ether platform_device_id entry
  sh_eth: Remove obsolete r8a779x-ether platform_device_id entries
  sh_eth: Remove obsolete r8a7740-gether platform_device_id entry
  sh_eth: Remove obsolete r8a777x-ether platform_device_id entry

 drivers/net/ethernet/renesas/sh_eth.c | 213 +++++++++++++++++-----------------
 1 file changed, 104 insertions(+), 109 deletions(-)

-- 
1.9.1

Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
