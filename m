From: KOVACS Krisztian <hidden@balabit.hu>
Subject: [PATCH/RFC 06/10] Create a tproxy flag in struct sk_buff
Date: Wed, 03 Jan 2007 17:36:58 +0100
Message-ID: <20070103163658.14635.64205.stgit@nienna.balabit>
References: <20070103163357.14635.37754.stgit@nienna.balabit>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org
In-Reply-To: <20070103163357.14635.37754.stgit@nienna.balabit>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

We would like to be able to match on whether or not a given packet has
been diverted by tproxy. To make this possible we need a flag in
sk_buff.

Signed-off-by: KOVACS Krisztian <hidden@balabit.hu>

---

 include/linux/skbuff.h |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
index 4ff3940..6d7f5c7 100644
--- a/include/linux/skbuff.h
+++ b/include/linux/skbuff.h
@@ -284,7 +284,8 @@ struct sk_buff {
 				nfctinfo:3;
 	__u8			pkt_type:3,
 				fclone:2,
-				ipvs_property:1;
+				ipvs_property:1,
+				ip_tproxy:1;
 	__be16			protocol;
 
 	void			(*destructor)(struct sk_buff *skb);
