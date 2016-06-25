From: Martin Blumenstingl <martin.blumenstingl@googlemail.com>
Subject: [RFC] meson: add support for configuring the ethernet clocks
Date: Sat, 25 Jun 2016 18:50:10 +0200
Message-ID: <20160625165013.15917-1-martin.blumenstingl@googlemail.com>
Cc: carlo@caione.org, khilman@baylibre.com, robh+dt@kernel.org,
	mark.rutland@arm.com, netdev@vger.kernel.org,
	peppe.cavallaro@st.com
To: linux-amlogic@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f65.google.com ([74.125.82.65]:36147 "EHLO
	mail-wm0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997AbcFYQuX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 12:50:23 -0400
Received: by mail-wm0-f65.google.com with SMTP id c82so13318721wme.3
        for <netdev@vger.kernel.org>; Sat, 25 Jun 2016 09:50:22 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This adds support for configuring the PRG_ETHERNET_ADDR registers on
Meson 8b (S805) and GXBB (S905) devices. The registers there are
completely different from those found in the earlier Meson 6b SoC
series, which is why a new driver was implemented.

This configuration is required when the bootloader does not configure
these registers based on the connected PHY. Symptoms are that the
DWMAC device is detected, but no packets are getting through, even
though everything else is configured correctly.
