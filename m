From: Paul Moore <paul.moore@hp.com>
Subject: [PATCH] One more XFRM audit fix
Date: Wed, 19 Dec 2007 14:29:31 -0500
Message-ID: <20071219192309.15561.9843.stgit@flek.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-audit@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:48177 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753156AbXLSTd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Dec 2007 14:33:27 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following patch is backed against David's net-2.6 tree and is pretty
trivial.  I know we're late in the 2.6.24 cycle but I think this is worth
merging, if you guys don't feel that way let me know and I'll resubmit it
for 2.6.25.

As a side note, I'm unable to actually test the patch because I can't get
the kernel to compile (M=net/xfrm works just fine).  The problem I keep
seeing is below:

make[3]: *** No rule to make target \
 `/blah/kernels/net-2.6_xfrm-auid-secid-fix/include/linux/ticable.h', \
  needed by \
 `/blah/kernels/net-2.6_xfrm-auid-secid-fix/usr/include/linux/ticable.h'. \
  Stop.

-- 
paul moore
linux security @ hp

