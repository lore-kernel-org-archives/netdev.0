From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Subject: About CFG80211_REQUIRE_SIGNED_REGDB in Kconfig
Date: Fri, 27 Oct 2017 05:01:17 +0000
Message-ID: <TY1PR06MB0992968BEEB32DA3164C9552D85A0@TY1PR06MB0992.apcprd06.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relmlor3.renesas.com ([210.160.252.173]:6672 "EHLO
        relmlie2.idc.renesas.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1750828AbdJ0FBU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Oct 2017 01:01:20 -0400
Received: from relmlii1.idc.renesas.com (relmlii1.idc.renesas.com [10.200.68.65])
        by relmlir2.idc.renesas.com (Postfix) with ESMTP id CCEB64F11E
        for <netdev@vger.kernel.org>; Fri, 27 Oct 2017 14:01:18 +0900 (JST)
Content-Language: ja-JP
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a question about CFG80211_REQUIRE_SIGNED_REGDB behavior in the lates=
t net-next.git.

Since my environment disables CONFIG_EXPERT, CFG80211_CERTIFICATION_ONUS is=
 also disabled.
In this case, menuconfig doesn't show me the config because the net/wireles=
s/Kconfig has:

config CFG80211_REQUIRE_SIGNED_REGDB
	bool "require regdb signature" if CFG80211_CERTIFICATION_ONUS
	default y
	select SYSTEM_DATA_VERIFICATION

Does this mean that non expert users should enable CFG80211_REQUIRE_SIGNED_=
REGDB anyway?
Or, does this have special other reasons?

Best regards,
Yoshihiro Shimoda
