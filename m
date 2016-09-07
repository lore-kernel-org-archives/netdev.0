From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: add missing header dependencies
Date: Wed, 7 Sep 2016 11:37:07 +0000
Message-ID: <DM5PR11MB1723D8845DD64E2634DBC41D97F80@DM5PR11MB1723.namprd11.prod.outlook.com>
References: <1473246420-1035-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "arnd@arndb.de" <arnd@arndb.de>,
        "xie.baoyou@zte.com.cn" <xie.baoyou@zte.com.cn>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0137.outbound.protection.outlook.com ([104.47.38.137]:49341
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750954AbcIGLhJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 07:37:09 -0400
In-Reply-To: <1473246420-1035-1-git-send-email-baoyou.xie@linaro.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> We get 4 warnings when building kernel with W=3D1:
> drivers/net/ethernet/qlogic/qed/qed_selftest.c:6:5: warning: no previous
> prototype for 'qed_selftest_memory' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_selftest.c:19:5: warning: no previous
> prototype for 'qed_selftest_interrupt' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_selftest.c:32:5: warning: no previous
> prototype for 'qed_selftest_register' [-Wmissing-prototypes]
> drivers/net/ethernet/qlogic/qed/qed_selftest.c:55:5: warning: no previous
> prototype for 'qed_selftest_clock' [-Wmissing-prototypes]
>=20
> In fact, these functions are declared in qed_selftest.h, so this patch ad=
d missing
> header dependencies.
>=20
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

While I obviously have no strong objection for including qed_selftest.h
from qed_selftest.c, I'm not sure I understand which C standard dictates
this requirement.
Why should a function definition [not call] be preceded by a prototype?
