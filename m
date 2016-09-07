From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH] qed: add missing header dependencies
Date: Wed, 7 Sep 2016 12:31:03 +0000
Message-ID: <DM5PR11MB17236A48767FEFB5C59426A297F80@DM5PR11MB1723.namprd11.prod.outlook.com>
References: <1473246420-1035-1-git-send-email-baoyou.xie@linaro.org>
 <DM5PR11MB1723D8845DD64E2634DBC41D97F80@DM5PR11MB1723.namprd11.prod.outlook.com>
 <4989831.9c6WyUak3s@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Baoyou Xie <baoyou.xie@linaro.org>,
        netdev <netdev@vger.kernel.org>,
        linux-kernel <linux-kernel@vger.kernel.org>,
        "xie.baoyou@zte.com.cn" <xie.baoyou@zte.com.cn>,
        Ariel Elior <Ariel.Elior@qlogic.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam03on0120.outbound.protection.outlook.com ([104.47.42.120]:33312
        "EHLO NAM03-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752767AbcIGMbG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Sep 2016 08:31:06 -0400
In-Reply-To: <4989831.9c6WyUak3s@wuerfel>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > While I obviously have no strong objection for including
> > qed_selftest.h from qed_selftest.c, I'm not sure I understand which C
> > standard dictates this requirement.
> > Why should a function definition [not call] be preceded by a prototype?
>=20
> - When a function is defined in one file and used in another, you want
>   both files to include the same header that has the declaration to
>   ensure that the types are identical. There are cases where the
>   prototype is changed after the fact in an incompatible way, causing
>   silent data corruption on some configurations but maybe not on others.

O.k., motivation is clear.
But this really isn't enforced by the ansi-c standard, right?

Anyway, thanks.

Acked-by: Yuval Mintz <Yuval.Mintz@qlogic.com>
