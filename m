From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net-next v2 1/2] qed: Add infrastructure for PTP support.
Date: Mon, 30 Jan 2017 18:00:46 +0000
Message-ID: <BL2PR07MB2306F664F2BB20FB5768A2798D4B0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1485674903-27689-1-git-send-email-Sudarsana.Kalluru@cavium.com>
 <1485674903-27689-2-git-send-email-Sudarsana.Kalluru@cavium.com>
 <20170129153134.GC2223@localhost.localdomain>
 <BL2PR07MB23065AC5421859AAC6D334348D480@BL2PR07MB2306.namprd07.prod.outlook.com>
 <20170129205156.GA30336@localhost.localdomain>
 <BL2PR07MB23063CA6DC624BDC4ABCCC268D480@BL2PR07MB2306.namprd07.prod.outlook.com>,<20170130132619.GA4854@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalluru, Sudarsana" <Sudarsana.Kalluru@cavium.com>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0085.outbound.protection.outlook.com ([104.47.33.85]:21568
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751406AbdA3SAt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 30 Jan 2017 13:00:49 -0500
In-Reply-To: <20170130132619.GA4854@localhost.localdomain>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > I might have gotten it all wrong, but I was under the assumption that t=
ime-
> > stamped packets are periodic, and that the interval between two isn't
> > going to be so small.

> That is an incorrect assumption.=A0 Consider the Delay_Req packets
> arriving on a port in the MASTER state.

Right; I was ignore that, thinking only on the clients.

> > Is so, how does having a couple of additional instructions in between
> > jeopardizes the next time stamp?

> It is not just about the few instructions, but there is also
> preemption possible.

I believe qede would only call this under spinlock, so that's probably
not an issue.
Regardless, that's no reason not to change the behavior.

Thanks.
     =
