From: Cong Wang <amwang@redhat.com>
Subject: [PATCH v2 net-next 0/4] ipv6: fix the reassembly expire code in nf_conntrack
Date: Tue, 18 Sep 2012 12:29:38 +0800
Message-ID: <1347942582-23962-1-git-send-email-amwang@redhat.com>
Cc: netfilter-devel@vger.kernel.org,
	Herbert Xu <herbert@gondor.hengli.com.au>,
	"David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

V2: use IS_ENABLED(CONFIG_IPV6) to fix a build error
    rebase to latest net-next

ipv6: add a new namespace for nf_conntrack_reasm
ipv6: unify conntrack reassembly expire code with standard one
ipv6: make ip6_frag_nqueues() and ip6_frag_mem() static
ipv6: unify fragment thresh handling code

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---

 include/net/inet_frag.h                 |    2 +-
 include/net/ipv6.h                      |   32 +++++-
 include/net/net_namespace.h             |    3 +
 include/net/netns/conntrack.h           |    6 +
 net/ipv4/inet_fragment.c                |    9 +-
 net/ipv4/ip_fragment.c                  |    5 +-
 net/ipv6/netfilter/nf_conntrack_reasm.c |  196 ++++++++++++++++---------------
 net/ipv6/reassembly.c                   |   88 ++++----------
 8 files changed, 176 insertions(+), 165 deletions(-)

