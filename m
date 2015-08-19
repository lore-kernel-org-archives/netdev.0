From: Jeremy Linton <jeremy.linton@arm.com>
Subject: [RFC/PATCH] xgene mac/phy cleanup
Date: Wed, 19 Aug 2015 13:56:41 -0500
Message-ID: <1440010602-5860-1-git-send-email-jeremy.linton@arm.com>
Content-Type: text/plain; charset=WINDOWS-1252
Content-Transfer-Encoding: quoted-printable
Cc: stripathi@apm.com, kchudgar@apm.com,
	brian.brooks.arm@vger.kernel.org, netdev@vger.kernel.org,
	jeremy.linton@arm.com
To: isubramanian@apm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([146.101.78.143]:34544 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750867AbbHSS4x (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Aug 2015 14:56:53 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch converts the xgene driver to use some common ACPI/DT agnostic
functions for retrieving MAC and PHY settings. I don't have a way to test
them at the moment, so if someone can verify they work that would be great.

BTW: These patches are against net-next.

Thanks,

Jeremy Linton (1):
  net: xgene Remove xgene specific phy and MAC lookup functions

 drivers/net/ethernet/apm/xgene/xgene_enet_main.c | 38 ++------------------=
----
 1 file changed, 2 insertions(+), 36 deletions(-)

--=20
2.4.3
