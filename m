From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2013-03-27
Date: Wed, 27 Mar 2013 08:41:05 +0100
Message-ID: <1364370068-20025-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:53927 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753842Ab3C0HlZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Mar 2013 03:41:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Initialize the satype field in key_notify_policy_flush(),
   this was left uninitialized. From Nicolas Dichtel.

2) The sequence number difference for replay notifications
   was misscalculated on ESN sequence number wrap. We need
   a separate replay notify function for esn.

3) Fix an off by one in the esn replay notify function.
   From Mathias Krause.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit a0b1c42951dd06ec83cc1bc2c9788131d9fefcd8:

  Merge git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next (2013-02-20 18:58:50 -0800)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to 799ef90c55e692e096d8bd9e5871b95264b1e9ba:

  xfrm: Fix esn sequence number diff calculation in xfrm_replay_notify_esn() (2013-03-25 07:25:50 +0100)

----------------------------------------------------------------
Mathias Krause (1):
      xfrm: Fix esn sequence number diff calculation in xfrm_replay_notify_esn()

Nicolas Dichtel (1):
      af_key: initialize satype in key_notify_policy_flush()

Steffen Klassert (1):
      xfrm: Fix replay notification for esn.

 net/key/af_key.c       |    1 +
 net/xfrm/xfrm_replay.c |   66 +++++++++++++++++++++++++++++++++++++++++++++++-
 2 files changed, 66 insertions(+), 1 deletion(-)
