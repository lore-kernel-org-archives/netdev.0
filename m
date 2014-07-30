From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2014-07-30
Date: Wed, 30 Jul 2014 13:12:25 +0200
Message-ID: <1406718748-21144-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43730 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752247AbaG3LM5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Jul 2014 07:12:57 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the last pull request for ipsec-next before I'll be
off for two weeks starting on friday. David, can you please
take urgent ipsec patches directly into net/net-next during
this time?

1) Error handling simplifications for vti and vti6.
   From Mathias Krause.

2) Remove a duplicate semicolon after a return statement.
   From Christoph Paasch.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 644a918d20336a7deaa81f675c3c2f25bf3dafbb:

  enic: Make dummy rfs functions inline to fix !CONFIG_RFS_ACCEL build (2014-06-25 18:04:41 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 1759389e8af46d724220785bf710b7bdbebdfa48:

  xfrm4: Remove duplicate semicolon (2014-06-30 07:49:47 +0200)

----------------------------------------------------------------
Christoph Paasch (1):
      xfrm4: Remove duplicate semicolon

Mathias Krause (2):
      vti6: Simplify error handling in module init and exit
      vti: Simplify error handling in module init and exit

 net/ipv4/ip_vti.c         | 54 ++++++++++++++++++-----------------------------
 net/ipv4/xfrm4_protocol.c |  2 +-
 net/ipv6/ip6_vti.c        | 51 ++++++++++++++++++--------------------------
 3 files changed, 42 insertions(+), 65 deletions(-)
