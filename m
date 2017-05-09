From: Ganesh GR <ganeshgr@chelsio.com>
Subject: Re: [PATCH 0/6] cxgb4: Fine-tuning for some function implementations
Date: Tue, 9 May 2017 09:40:47 +0000
Message-ID: <CY4PR12MB1432C4CD9C354BF03E4B1776C1EF0@CY4PR12MB1432.namprd12.prod.outlook.com>
References: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: LKML <linux-kernel@vger.kernel.org>,
        "kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: SF Markus Elfring <elfring@users.sourceforge.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Casey Leedom <leedom@chelsio.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <a3216042-2461-b397-dfa1-1de178d58513@users.sourceforge.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Acked-by: Ganesh Goudar <ganeshgr@chelsio.com>





From: SF Markus Elfring <elfring@users.sourceforge.net>
Sent: Friday, May 5, 2017 2:00 AM
To: netdev@vger.kernel.org; Casey Leedom; Ganesh GR
Cc: LKML; kernel-janitors@vger.kernel.org
Subject: [PATCH 0/6] cxgb4: Fine-tuning for some function implementations
=A0  =20
From: Markus Elfring <elfring@users.sourceforge.net>
Date: Thu, 4 May 2017 22:23:45 +0200

A few update suggestions were taken into account
from static source code analysis.

Markus Elfring (6):
=A0 Use seq_putc() in mboxlog_show()
=A0 Combine substrings for 24 messages
=A0 Adjust five checks for null pointers
=A0 Replace seven seq_puts() calls by seq_putc()
=A0 Use seq_puts() in cim_qcfg_show()
=A0 Combine substrings for two messages

=A0drivers/net/ethernet/chelsio/cxgb4/cxgb4_debugfs.c |=A0 42 +++----
=A0.../net/ethernet/chelsio/cxgb4vf/cxgb4vf_main.c=A0=A0=A0 | 125 +++++++++=
+++---------
=A02 files changed, 86 insertions(+), 81 deletions(-)

--=20
2.12.2

    =
