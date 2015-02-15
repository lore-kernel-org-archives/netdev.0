From: Denis Kirjanov <kda@linux-powerpc.org>
Subject: [PATCH net-next 0/6] bpf: Enable BPF JIT on ppc32
Date: Sun, 15 Feb 2015 21:06:39 +0300
Message-ID: <1424023605-2416-1-git-send-email-kda@linux-powerpc.org>
Cc: linuxppc-dev@lists.ozlabs.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f47.google.com ([209.85.215.47]:41418 "EHLO
	mail-la0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932069AbbBOSDG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 15 Feb 2015 13:03:06 -0500
Received: by labpv20 with SMTP id pv20so24426452lab.8
        for <netdev@vger.kernel.org>; Sun, 15 Feb 2015 10:03:04 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series enables BPF JIT on ppc32. There are relatevily
few chnages in the code to make it work.

All test_bpf tests passed both on 7447a and P2041-based machines.

 arch/powerpc/Kconfig                  |   2 +-
 arch/powerpc/include/asm/asm-compat.h |   4 +
 arch/powerpc/include/asm/ppc-opcode.h |   2 +
 arch/powerpc/net/Makefile             |   2 +-
 arch/powerpc/net/bpf_jit.h            |  47 ++++++-
 arch/powerpc/net/bpf_jit_64.S         | 229 ----------------------------------
 arch/powerpc/net/bpf_jit_asm.S        | 229 ++++++++++++++++++++++++++++++++++
 arch/powerpc/net/bpf_jit_comp.c       |  32 ++---
 8 files changed, 300 insertions(+), 247 deletions(-)
