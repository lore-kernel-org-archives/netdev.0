From: "Tayar, Tomer" <Tomer.Tayar@cavium.com>
Subject: RE: [RFC] endianness issues in drivers/net/ethernet/qlogic/qed
Date: Sun, 24 Sep 2017 14:34:19 +0000
Message-ID: <BN3PR0701MB15918FECAEB8503920850A7580650@BN3PR0701MB1591.namprd07.prod.outlook.com>
References: <20170918174940.GB32076@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "Elior, Ariel" <Ariel.Elior@cavium.com>,
        David Miller <davem@davemloft.net>
To: Al Viro <viro@ZenIV.linux.org.uk>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-cys01nam02on0081.outbound.protection.outlook.com ([104.47.37.81]:57630
        "EHLO NAM02-CY1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752244AbdIXOeW (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 24 Sep 2017 10:34:22 -0400
In-Reply-To: <20170918174940.GB32076@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> 	"qed: Utilize FW 8.10.3.0" has attempted some endianness annotations
> in that driver; unfortunately, either annotations are BS or the driver is=
 genuinely
> broken on big-endian hosts.
[...]
> Is that driver intended to be used on big-endian hosts at all?

Thanks for taking the time to review our driver and pointing out these mist=
akes.
Support for BE machines is planned to be added but currently it is not avai=
lable.
However, the structures which are used to abstract the HW carry endianity a=
nnotations.
Obviously, there are some misses and some annotations were added when not r=
equired.
We will prepare a patch that fixes the issues you pointed out and similar o=
nes.
