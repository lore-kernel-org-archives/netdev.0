From: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Subject: Re: [PATCH v2 net-next 0/7] qed*: RDMA and infrastructure for iWARP
Date: Sun, 18 Jun 2017 17:54:49 +0000
Message-ID: <BLUPR0701MB20047CD16002072436A61EA38DC70@BLUPR0701MB2004.namprd07.prod.outlook.com>
References: <20170618115035.2156-1-Yuval.Mintz@cavium.com>,<20170618.122901.124548969151925362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "Kalderon, Michal" <Michal.Kalderon@cavium.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-co1nam03on0068.outbound.protection.outlook.com ([104.47.40.68]:9536
        "EHLO NAM03-CO1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751030AbdFRRyy (ORCPT <rfc822;netdev@vger.kernel.org>);
        Sun, 18 Jun 2017 13:54:54 -0400
In-Reply-To: <20170618.122901.124548969151925362.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I'm still not happy at all.
> You failed the address the specific thing I asked to be fixed.

> In patch #4, the rename, you just say in your commit message
> that you are "renaming".

> But in the qedr/main.c part of the change, you are _REMOVING_
> the include.

> And I said that can't be right if all you are doing is renaming the
> files.

It's a redundant inclusion as qedr.h already includes the
interface file and gets included in turn by main.c.
We're not REALLY changing anything significant here; It's a very minor
cleanup as part of the patch.

> So either fix that part of the change to actually rename the include
> header, rather than removing the include, or explain _IN DETAIL_ in
> the commit log message why removing it is the right thing to do and
> especially _WHY_ it is appropriate for it to be done as part of the
> renaming patch.

I can't really say I understand who would benefit from adding=20
"while at it remove redundant inclusion of header file"
to the commit log message [And even less from splitting this into its own p=
atch].

But you're the chief; so we will.
=20
> Can you understand how inconsistent it is to have a patch that says
> nothing more than "I'm renaming files" and yet have other stuff
> happening?     =
