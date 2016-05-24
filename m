From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: [iproute2 1/1] tc simple action: bug fix
Date: Mon, 23 May 2016 21:04:53 -0400
Message-ID: <1464051893-25680-1-git-send-email-jhs@emojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, daniel@iogearbox.net,
	Jamal Hadi Salim <jhs@mojatatu.com>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f67.google.com ([209.85.214.67]:34141 "EHLO
	mail-it0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751599AbcEXBFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 21:05:06 -0400
Received: by mail-it0-f67.google.com with SMTP id k76so554301ita.1
        for <netdev@vger.kernel.org>; Mon, 23 May 2016 18:05:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jamal Hadi Salim <jhs@mojatatu.com>

=46ailed compile
m_simple.c: In function =E2=80=98parse_simple=E2=80=99:
m_simple.c:154:6: warning: too many arguments for format [-Wformat-extr=
a-args]
      *argv);
      ^
m_simple.c:103:14: warning: unused variable =E2=80=98maybe_bind=E2=80=99=
 [-Wunused-variable]

Reported-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
---
 tc/m_simple.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/tc/m_simple.c b/tc/m_simple.c
index 11d4869..8b3d655 100644
--- a/tc/m_simple.c
+++ b/tc/m_simple.c
@@ -150,7 +150,7 @@ parse_simple(struct action_util *a, int *argc_p, ch=
ar ***argv_p, int tca_id,
 		if (matches(*argv, "index") =3D=3D 0) {
 			NEXT_ARG();
 			if (get_u32(&sel.index, *argv, 10)) {
-				fprintf(stderr, "simple: Illegal \"index\"\n",
+				fprintf(stderr, "simple: Illegal \"index\" (%s)\n",
 					*argv);
 				return -1;
 			}
--=20
1.9.1
