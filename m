From: David Howells <dhowells@redhat.com>
Subject: Re: [PATCH 00/14] AF_RXRPC socket family and AFS rewrite [net-2.6]
Date: Fri, 27 Apr 2007 15:28:26 +0100
Message-ID: <23441.1177684106@redhat.com>
References: <20070426.204112.118626412.davem@davemloft.net>  <20070426195415.24531.78794.stgit@warthog.cambridge.redhat.com> <20070426.161522.76328746.davem@davemloft.net> <20070426.200809.04441500.davem@davemloft.net>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:46073 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755855AbXD0O2c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 10:28:32 -0400
In-Reply-To: <20070426.204112.118626412.davem@davemloft.net> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:

> Here is how I'm fixing this for now to get the tree into
> a buildable state.

Okay, that looks mostly reasonable, but it needs to go a little bit further.

> If you have a better fix, please send it to me relative
> to what's in net-2.6, thanks.

I'm about to dispatch three patches to you:

 (1) Extend your fixes to the VL update manager.  The state changing to
     AFS_VL_VALID isn't the only place a wakeup is missing.

 (2) I compiled against all of these arches in addition to x86_64:

	i386, frv, frv (nommu), pa-risc, s390, powerpc (16 & 32), sparc64,
	mips, alpha, ia64.

     And came up with a few more problems, notably wrt to compiling the
     modules in.

     Due to general arch problems, I tried and failed to build for:

	m68k, cris, arm, h8300, sh, v850, sparc.

     Due to lack of a suitable compiler, I couldn't build for:

	sh64, xtensa

 (3) I also came across some other networking compilation bugs.

David
