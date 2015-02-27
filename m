From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2] m_bpf: remove unrelevant help lines
Date: Fri, 27 Feb 2015 17:52:36 +0100
Message-ID: <87dce322a047ddf136fa5705b2dc61b58ad514f3.1425055793.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Jiri Pirko <jiri@resnulli.us>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:56742 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693AbbB0Qwk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 11:52:40 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Left-overs when copying this over from cls_bpf. ;) Lets remove them.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Jiri Pirko <jiri@resnulli.us>
---
 tc/m_bpf.c | 2 --
 1 file changed, 2 deletions(-)

diff --git a/tc/m_bpf.c b/tc/m_bpf.c
index 611135e..3b864f9 100644
--- a/tc/m_bpf.c
+++ b/tc/m_bpf.c
@@ -31,8 +31,6 @@ static void explain(void)
 	fprintf(stderr, "Where BPF_BYTECODE := \'s,c t f k,c t f k,c t f k,...\'\n");
 	fprintf(stderr, "      c,t,f,k and s are decimals; s denotes number of 4-tuples\n");
 	fprintf(stderr, "Where FILE points to a file containing the BPF_BYTECODE string\n");
-	fprintf(stderr, "\nACTION_SPEC := ... look at individual actions\n");
-	fprintf(stderr, "NOTE: CLASSID is parsed as hexadecimal input.\n");
 }
 
 static void usage(void)
-- 
1.9.3
