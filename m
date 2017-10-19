From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 4/8] tools: bpftool: add `bpftool prog help` as real command i.r.t exit code
Date: Thu, 19 Oct 2017 15:46:22 -0700
Message-ID: <20171019224626.31608-5-jakub.kicinski@netronome.com>
References: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Quentin Monnet <quentin.monnet@netronome.com>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:48373 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753115AbdJSWrJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 18:47:09 -0400
Received: by mail-pf0-f195.google.com with SMTP id b79so8111760pfk.5
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 15:47:09 -0700 (PDT)
In-Reply-To: <20171019224626.31608-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Quentin Monnet <quentin.monnet@netronome.com>

Make error messages and return codes more consistent. Specifically, make
`bpftool prog help` a real command, instead of printing usage by default
for a non-recognized "help" command. Output is the same, but this makes
bpftool return with a success value instead of an error.

Signed-off-by: Quentin Monnet <quentin.monnet@netronome.com>
Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 tools/bpf/bpftool/prog.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/tools/bpf/bpftool/prog.c b/tools/bpf/bpftool/prog.c
index 6c03d2ea3f79..355c14325622 100644
--- a/tools/bpf/bpftool/prog.c
+++ b/tools/bpf/bpftool/prog.c
@@ -475,6 +475,7 @@ static int do_help(int argc, char **argv)
 
 static const struct cmd cmds[] = {
 	{ "show",	do_show },
+	{ "help",	do_help },
 	{ "dump",	do_dump },
 	{ "pin",	do_pin },
 	{ 0 }
-- 
2.14.1
