From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2013-06-26
Date: Wed, 26 Jun 2013 14:01:37 +0200
Message-ID: <1372248098-19876-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:54337 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752013Ab3FZMCH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 08:02:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just one patch this time.

1) Drop packets when the matching SA is in larval state and add a
   statistic counter for that. From Fan Du.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit 5865fc1b6a99bc7dcf245770c2735577b8596b6e:

  tg3: remove redundant pm init code (2013-06-03 00:48:11 -0700)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 4c4d41f200db375b2d2cc6d0a1de0606c8266398:

  xfrm: add LINUX_MIB_XFRMACQUIREERROR statistic counter (2013-06-06 06:45:55 +0200)

----------------------------------------------------------------
Fan Du (1):
      xfrm: add LINUX_MIB_XFRMACQUIREERROR statistic counter

 include/uapi/linux/snmp.h |    1 +
 net/xfrm/xfrm_input.c     |    5 +++++
 net/xfrm/xfrm_proc.c      |    1 +
 3 files changed, 7 insertions(+)
