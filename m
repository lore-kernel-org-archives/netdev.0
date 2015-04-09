From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2015-04-09
Date: Thu, 9 Apr 2015 12:33:07 +0200
Message-ID: <1428575588-24962-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:43792 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753639AbbDIKdP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Apr 2015 06:33:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Prohibit the use/abuse of the xfrm netlink interface on
   32/64 bit compatibility tasks. We need a full compat
   layer before we can allow this. From Fan Du.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit b898441f4ece44933af90b116b467f7864dd1ae7:

  Merge branch 'neigh_cleanups' (2015-03-02 16:43:46 -0500)

are available in the git repository at:


  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to 74005991b78a0a7a6546004fb37d33a651c613e7:

  xfrm: Do not parse 32bits compiled xfrm netlink msg on 64bits host (2015-03-03 10:10:16 +0100)

----------------------------------------------------------------
Fan Du (1):
      xfrm: Do not parse 32bits compiled xfrm netlink msg on 64bits host

 net/xfrm/xfrm_user.c | 5 +++++
 1 file changed, 5 insertions(+)
