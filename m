From: Sergey Senozhatsky <sergey.senozhatsky@mail.by>
Subject: [PATCH]: fixing gcc 4.4 =?utf-8?Q?compiler?=
	=?utf-8?Q?_warning=3A_suggest_parentheses_around_operand_of_=E2=80=98!?=
	=?utf-8?B?4oCZ?=
Date: Thu, 30 Apr 2009 09:06:16 +0300
Message-ID: <20090430060616.GB6040@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.98.175.89] ([212.98.175.89]:50298 "EHLO
	localhost.localdomain" rhost-flags-FAIL-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750736AbZD3T3W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2009 15:29:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trivial: fixing gcc 4.4 compiler warning:
drivers/net/cxgb3/t3_hw.c: In function =E2=80=98t3_prep_adapter=E2=80=99=
:
drivers/net/cxgb3/t3_hw.c:3782: warning: suggest parentheses around ope=
rand of =E2=80=98!=E2=80=99 or change =E2=80=98|=E2=80=99 to =E2=80=98|=
|=E2=80=99 or =E2=80=98!=E2=80=99 to =E2=80=98~=E2=80=99

Signed-off-by: Sergey Senozhatsky <sergey.senozhatsky@mail.by>

---

diff --git a/drivers/net/cxgb3/t3_hw.c b/drivers/net/cxgb3/t3_hw.c
index e1bd690..4f68aeb 100644
--- a/drivers/net/cxgb3/t3_hw.c
+++ b/drivers/net/cxgb3/t3_hw.c
@@ -3779,7 +3779,7 @@ int t3_prep_adapter(struct adapter *adapter, cons=
t struct adapter_info *ai,
=20
 	adapter->params.info =3D ai;
 	adapter->params.nports =3D ai->nports0 + ai->nports1;
-	adapter->params.chan_map =3D !!ai->nports0 | (!!ai->nports1 << 1);
+	adapter->params.chan_map =3D (!!ai->nports0) | (!!ai->nports1 << 1);
 	adapter->params.rev =3D t3_read_reg(adapter, A_PL_REV);
 	/*
 	 * We used to only run the "adapter check task" once a second if

