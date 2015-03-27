From: Stas Sergeev <stsp@list.ru>
Subject: [PATCH 0/6] mvneta: SGMII-based in-band link state signaling
Date: Fri, 27 Mar 2015 16:28:28 +0300
Message-ID: <55155AFC.4050800@list.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Linux kernel <linux-kernel@vger.kernel.org>,
	Stas Sergeev <stsp@users.sourceforge.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp49.i.mail.ru ([94.100.177.109]:37828 "EHLO smtp49.i.mail.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752511AbbC0N2d (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Mar 2015 09:28:33 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

Currently the fixed-link DT binding is pre-configured and
cannot be changed in run-time. This means the cable unplug
events are not being detected, and the link parameters can't
be negotiated.

The following patches are needed when mvneta is used
in fixed-link mode (without MDIO).
They add an API to of_mdio for updating the fixed_phy
status, and use that API in the mvneta driver when parsing
the SGMII in-band status.

Signed-off-by: Stas Sergeev <stsp@users.sourceforge.net>
