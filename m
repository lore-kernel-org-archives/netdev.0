From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request: ipsec-next 2012-11-22
Date: Thu, 22 Nov 2012 09:02:38 +0100
Message-ID: <1353571362-6774-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:36101 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932385Ab2KVTBS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Nov 2012 14:01:18 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This pull request is intended for net-next and contains the following changes:

1) Remove a redundant check when initializing the xfrm replay functions,
   from Ulrich Weber.
2) Use a faster per-cpu helper when allocating ipcomt transforms,
   from Shan Wei.
3) Use a static gc threshold value for ipv6, simmilar to what we do
   for ipv4 now.
4) Remove a commented out function call.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit f1e0b5b4f1eae56a3192688177f36e2bdf0e01ac:

  Merge tag 'batman-adv-for-davem' of git://git.open-mesh.org/linux-merge (2012-11-07 19:08:42 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 0afe21fdf6cfe0fe8a184d82a399773cc331bf40:

  xfrm6: Remove commented out function call to xfrm6_input_fini (2012-11-16 08:07:56 +0100)

----------------------------------------------------------------
Shan Wei (1):
      net: xfrm: use __this_cpu_read per-cpu helper

Steffen Klassert (2):
      xfrm: Use a static gc threshold value for ipv6
      xfrm6: Remove commented out function call to xfrm6_input_fini

Ulrich Weber (1):
      xfrm: remove redundant replay_esn check

 net/ipv6/xfrm6_policy.c |   17 +----------------
 net/xfrm/xfrm_ipcomp.c  |    8 +++-----
 net/xfrm/xfrm_replay.c  |   13 ++++++-------
 3 files changed, 10 insertions(+), 28 deletions(-)
