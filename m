From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH iproute2 -next v2 0/2] f_bpf update
Date: Mon, 16 Mar 2015 19:37:39 +0100
Message-ID: <cover.1426530729.git.daniel@iogearbox.net>
Cc: jhs@mojatatu.com, jiri@resnulli.us, ast@plumgrid.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:43553 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754454AbbCPShq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2015 14:37:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen,

Patch 1 can optionally be dropped when you do the header rebase yourself. I
have included it here just in case.

Thanks a lot!

v1->v2:
  - Elaborated on comment in patch2 as suggested by Alexei
  - Rest as is

Daniel Borkmann (2):
  misc: header rebase, add bpf.h
  tc: add eBPF support to f_bpf

 configure           |  26 ++++
 include/linux/bpf.h | 183 ++++++++++++++++++++++++
 include/utils.h     |   5 +
 tc/Makefile         |   5 +
 tc/f_bpf.c          |  36 +++--
 tc/tc_bpf.c         | 392 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 tc/tc_bpf.h         |  58 +++++++-
 7 files changed, 694 insertions(+), 11 deletions(-)
 create mode 100644 include/linux/bpf.h

-- 
1.9.3
