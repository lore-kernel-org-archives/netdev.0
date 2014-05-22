From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2014-05-22
Date: Thu, 22 May 2014 11:06:35 +0200
Message-ID: <1400749598-29603-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:45164 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752409AbaEVJGw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 May 2014 05:06:52 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the last ipsec pull request before I leave for
a three weeks vacation tomorrow. David, can you please
take urgent ipsec patches directly into net/net-next
during this time?

I'll continue to run the ipsec/ipsec-next trees as soon
as I'm back.

1) Simplify the xfrm audit handling, from Tetsuo Handa.

2) Codingstyle cleanup for xfrm_output, from abian Frederick.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 5a9d19ab76f98b7cdc97ba9724be01deba791bc0:

  Merge branch 'ndo_set_config' (2014-04-21 14:59:29 -0400)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to fc68086ce888a10220c7c79a2a3b44cb85d4074c:

  net/xfrm/xfrm_output.c: move EXPORT_SYMBOL (2014-05-13 12:44:28 +0200)

----------------------------------------------------------------
Fabian Frederick (1):
      net/xfrm/xfrm_output.c: move EXPORT_SYMBOL

Tetsuo Handa (2):
      xfrm: Remove useless secid field from xfrm_audit.
      xfrm: Remove useless xfrm_audit struct.

 include/net/xfrm.h     |   57 +++++++++++++++++++-----------------------------
 net/key/af_key.c       |   32 ++++++---------------------
 net/xfrm/xfrm_output.c |    5 ++---
 net/xfrm/xfrm_policy.c |   46 ++++++++++++--------------------------
 net/xfrm/xfrm_state.c  |   37 ++++++++++---------------------
 net/xfrm/xfrm_user.c   |   53 +++++++-------------------------------------
 6 files changed, 65 insertions(+), 165 deletions(-)
