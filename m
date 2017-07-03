From: "Kalderon, Michal" <Michal.Kalderon@cavium.com>
Subject: Re: [PATCH net-next 00/12] qed: Add iWARP support for QL4xxxx
Date: Mon, 3 Jul 2017 18:31:49 +0000
Message-ID: <BY1PR0701MB138196EA2A6E51B9D27AC51788D60@BY1PR0701MB1381.namprd07.prod.outlook.com>
References: <1498980572-29519-1-git-send-email-Michal.Kalderon@cavium.com>
        <20170703.014708.552467938183415134.davem@davemloft.net>,<20170703.015912.1508299432366405008.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-7"
Content-Transfer-Encoding: quoted-printable
Cc: "Amrani, Ram" <Ram.Amrani@cavium.com>,
        "Mintz, Yuval" <Yuval.Mintz@cavium.com>,
        "Elior, Ariel" <Ariel.Elior@cavium.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "dledford@redhat.com" <dledford@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2nam02on0058.outbound.protection.outlook.com ([104.47.38.58]:63664
        "EHLO NAM02-BL2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1752229AbdGCSbz (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 3 Jul 2017 14:31:55 -0400
In-Reply-To: <20170703.015912.1508299432366405008.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Sent: Monday, July 3, 2017 11:59 AM

> You really have to compile test your work and do something with
> the warnings:

> drivers/net/ethernet/qlogic/qed/qed_iwarp.c:1721:5: warning: =A1ll2_syn_h=
andle=A2 may be used uninitialized in this funct

> This one is completely legitimate, you can goto "err" and use
> the ll2_syn_handle without it being initialized.

Sorry about that, this warning didn't appear locally (gcc 4.8.5).
Fix is on its way (after verifying with newer gcc).
