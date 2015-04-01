From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH v3 0/2] mvneta: SGMII-based in-band link state signaling
Date: Wed, 01 Apr 2015 20:28:25 +0300
Message-ID: <551C2AB9.8020508@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Currently the fixed-link DT binding is pre-configured and
cannot be changed in run-time. This means the cable unplug
events are not being detected, and the link parameters can't
be negotiated.

The following patches are needed when mvneta is used
in fixed-link mode (without MDIO).
They add an API to fixed_phy that allows to update
status, and use that API in the mvneta driver when parsing
the SGMII in-band status.

There is also another implementation that doesn't add any API
and does everything in mvneta driver locally:
https://lkml.org/lkml/2015/3/31/327
I'll let people decide which approach is better.
No strong opinion on my side.

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
