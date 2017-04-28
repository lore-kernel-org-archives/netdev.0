From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net): ipsec 2017-04-28
Date: Fri, 28 Apr 2017 11:14:31 +0200
Message-ID: <1493370873-30836-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:58134 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1163924AbdD1JtD (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 05:49:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

1) Do garbage collecting after a policy flush to remove old
   bundles immediately. From Xin Long.

2) Fix GRO if netfilter is not defined.
   From Sabrina Dubroca.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit fd2c83b35752f0a8236b976978ad4658df14a59f:

  net/packet: check length in getsockopt() called with PACKET_HDRLEN (2017-04-25 14:05:52 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec.git master

for you to fetch changes up to cfcf99f987ba321a3d122580716beb9b08d52eb8:

  xfrm: fix GRO for !CONFIG_NETFILTER (2017-04-27 12:20:19 +0200)

----------------------------------------------------------------
Sabrina Dubroca (1):
      xfrm: fix GRO for !CONFIG_NETFILTER

Xin Long (1):
      xfrm: do the garbage collection after flushing policy

 net/xfrm/xfrm_input.c  | 2 +-
 net/xfrm/xfrm_policy.c | 4 ++++
 2 files changed, 5 insertions(+), 1 deletion(-)
