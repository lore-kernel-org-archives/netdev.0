From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2015-01-26
Date: Mon, 26 Jan 2015 08:48:21 +0100
Message-ID: <1422258503-26978-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	<netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:34916 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751427AbbAZHse (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Jan 2015 02:48:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just two small fixes for _decode_session6() where we
might decode to wrong header information in some rare
situations.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit f2a01517f2a1040a0b156f171a7cefd748f2fd03:

  openvswitch: Fix flow mask validation. (2014-12-05 21:42:16 -0800)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to f855691975bb06373a98711e4cfe2c224244b536:

  xfrm6: Fix the nexthdr offset in _decode_session6. (2014-12-08 07:56:18 +0100)

----------------------------------------------------------------
Steffen Klassert (2):
      xfrm6: Fix transport header offset in _decode_session6.
      xfrm6: Fix the nexthdr offset in _decode_session6.

 net/ipv6/xfrm6_policy.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)
