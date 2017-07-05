From: kbuild test robot <fengguang.wu@intel.com>
Subject: [RFC PATCH linus] tcp: md5: tcp_md5_do_lookup_exact() can be static
Date: Thu, 6 Jul 2017 07:58:53 +0800
Message-ID: <20170705235853.GA69361@lkp-sb04.lkp.intel.com>
References: <201707060719.Zvm7chOj%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kbuild-all@01.org, linux-kernel@vger.kernel.org,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201707060719.Zvm7chOj%fengguang.wu@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Fixes: 0c5f0311f690 ("Add linux-next specific files for 20170705")
Signed-off-by: Fengguang Wu <fengguang.wu@intel.com>
---
 tcp_ipv4.c |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/net/ipv4/tcp_ipv4.c b/net/ipv4/tcp_ipv4.c
index 6ec6900..a20e7f0 100644
--- a/net/ipv4/tcp_ipv4.c
+++ b/net/ipv4/tcp_ipv4.c
@@ -943,9 +943,9 @@ struct tcp_md5sig_key *tcp_md5_do_lookup(const struct sock *sk,
 }
 EXPORT_SYMBOL(tcp_md5_do_lookup);
 
-struct tcp_md5sig_key *tcp_md5_do_lookup_exact(const struct sock *sk,
-					       const union tcp_md5_addr *addr,
-					       int family, u8 prefixlen)
+static struct tcp_md5sig_key *tcp_md5_do_lookup_exact(const struct sock *sk,
+						      const union tcp_md5_addr *addr,
+						      int family, u8 prefixlen)
 {
 	const struct tcp_sock *tp = tcp_sk(sk);
 	struct tcp_md5sig_key *key;
