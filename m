From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH net-next 10/11] qede: Add basic XDP support
Date: Mon, 28 Nov 2016 20:20:42 +0000
Message-ID: <BL2PR07MB2306DCDA5176014107028C9F8D8A0@BL2PR07MB2306.namprd07.prod.outlook.com>
References: <1480258273-24973-1-git-send-email-Yuval.Mintz@cavium.com>
        <1480258273-24973-11-git-send-email-Yuval.Mintz@cavium.com>,<20161128191832.46191e1c@jkicinski-Precision-T1700>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "davem@davemloft.net" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jakub Kicinski <kubakici@wp.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0064.outbound.protection.outlook.com ([104.47.36.64]:44179
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751824AbcK1UUo (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Nov 2016 15:20:44 -0500
In-Reply-To: <20161128191832.46191e1c@jkicinski-Precision-T1700>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Any particular reason not to allow the XDP prog being set while the
> device is closed?=A0 You seem to preserve the program across
> close()/open() cycles so the edev->xdp_prog is alive and valid while
> device is closed IIUC.=A0=20

> I think other drivers are allowing setting XDP while closed and it
> would be cool to keep the behaviour identical across drivers :)

You're right; No reason to prevent this.
I'll fix it in v2.
