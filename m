From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: pull request (net-next): ipsec-next 2017-04-28
Date: Fri, 28 Apr 2017 10:42:37 +0200
Message-ID: <1493368958-29609-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:59784 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1165155AbdD1KLt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 28 Apr 2017 06:11:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Just one patch to fix a misplaced spin_unlock_bh in an error path.

Please pull or let me know if there are problems.

Thanks!

The following changes since commit e2989ee9746b3f2e78d1a39bbc402d884e8b8bf1:

  bpf, doc: update list of architectures that do eBPF JIT (2017-04-23 15:56:48 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next.git master

for you to fetch changes up to e892d2d40445a14a19530a2be8c489b87bcd7c19:

  esp: Fix misplaced spin_unlock_bh. (2017-04-24 07:56:31 +0200)

----------------------------------------------------------------
Steffen Klassert (1):
      esp: Fix misplaced spin_unlock_bh.

 net/ipv4/esp4.c | 6 +-----
 net/ipv6/esp6.c | 6 +-----
 2 files changed, 2 insertions(+), 10 deletions(-)
