From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Mon, 30 Jan 2017 17:55:32 +0000
Message-ID: <BL2PR07MB2306B5963EBDEF0AF5CD4E8F8D4B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153536.GD2223@localhost.localdomain>,<063D6719AE5E284EB5DD2968C1650D6DB0273BA8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        'Richard Cochran' <richardcochran@gmail.com>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-dm3nam03on0058.outbound.protection.outlook.com ([104.47.41.58]:45504
        "EHLO NAM03-DM3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1750866AbdA3SKu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 13:10:50 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0273BA8@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> How many different implementations of 'ops->adjfreq' are there?
> If there is only one you don't need an indirect call.

There's only one implementation. But qed publishes its functions to
qede [and other modules] by structs of operations and not by
exporting symbols directly, and I don't see a reason to change that
paradigm here.
[Although I might be mistaken about that last bit]
     =
