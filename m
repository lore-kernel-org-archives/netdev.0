From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: RE: [PATCH net-next v2 2/2] qede: Add driver support for PTP.
Date: Tue, 31 Jan 2017 14:31:41 +0000
Message-ID: <BL2PR07MB23068B30A71CB67A8DE673E48D4A0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-3-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153536.GD2223@localhost.localdomain>,<063D6719AE5E284EB5DD2968C1650D6DB0273BA8@AcuExch.aculab.com>
 <BL2PR07MB2306B5963EBDEF0AF5CD4E8F8D4B0@BL2PR07MB2306.namprd07.prod.outlook.com>
 <063D6719AE5E284EB5DD2968C1650D6DB02749AC@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
        'Richard Cochran' <richardcochran@gmail.com>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam01on0060.outbound.protection.outlook.com ([104.47.32.60]:8928
        "EHLO NAM01-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752386AbdAaOcF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 31 Jan 2017 09:32:05 -0500
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB02749AC@AcuExch.aculab.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > > How many different implementations of 'ops->adjfreq' are there?
> > > If there is only one you don't need an indirect call.
> >
> > There's only one implementation. But qed publishes its functions to
> > qede [and other modules] by structs of operations and not by exporting
> > symbols directly, and I don't see a reason to change that paradigm
> > here.
> > [Although I might be mistaken about that last bit]
>=20
> If any of the functions are on 'hot paths' the cost of the indirect call =
is likely
> to be measurable.
> On a lot of cpus it will be a pipeline stall.
> The double-indirect almost certainly generates a stall.

I feel like I'm missing something. Again.
I thought the reasonable rate of rate-adjustment is once a second,
which doesn't make it 'hot' in any way.
In which scenario would we frequently encounter this configuration?
