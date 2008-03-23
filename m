From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: [PATCH 0 of 5] IPv6: Fix temporary address support
Date: Sun, 23 Mar 2008 21:46:08 +0100
Message-ID: <patchbomb.1206305168@pirzuine>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp8-g19.free.fr ([212.27.42.65]:38104 "EHLO smtp8-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753251AbYCWUqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Mar 2008 16:46:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the set of patches I needed to make IPv6 temporary addresses
work in my setup.

First my ISP advertizes 2 prefixes, this was not tested with the current code.
Next one of the prefix has a preferred lifetime of 0, the current code
didn't follow the rfc (no temporary addresses should be created in this case).
Finally the other patch results from my test using a small tmp_preferred_lifetime
and the issues I encountered in this case.

The second patch is probably the most important of the serie and worth applying
to stable, without it I can't use temporary addresses.

Please review and consider applying.

Benoit

PS: I noticed that MAX_DESYNC_FACTOR was used to calculated the preferred
    lifetime, instead of a random number between 0 and MAX_DESYNC_FACTOR. Is
    this on purpose, or should a write a patch ?
