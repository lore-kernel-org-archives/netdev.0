From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH 3/4]net:ipv6:fixed spacing issues related to < operator
Date: Tue, 22 May 2012 00:34:27 +0530
Message-ID: <1337627067-3350-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: davem@davemloft.net, edumazet@google.com, loke.chetan@gmail.com,
	herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed spacing issues relating to < operator
found in net/ipv6/mcast.c by checkpatch.pl tool

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/ipv6/mcast.c |   24 ++++++++++++------------
 1 file changed, 12 insertions(+), 12 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 66235a0..541893d 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -369,7 +369,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		if (!psl)
 			goto done;	/* err = -EADDRNOTAVAIL */
 		rv = !0;
-		for (i = 0; i<psl->sl_count; i++) {
+		for (i = 0; i < psl->sl_count; i++) {
 			rv = memcmp(&psl->sl_addr[i], source,
 				sizeof(struct in6_addr));
 			if (rv == 0)
@@ -387,7 +387,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		/* update the interface filter */
 		ip6_mc_del_src(idev, group, omode, 1, source, 1);
 
-		for (j = i+1; j<psl->sl_count; j++)
+		for (j = i+1; j < psl->sl_count; j++)
 			psl->sl_addr[j-1] = psl->sl_addr[j];
 		psl->sl_count--;
 		err = 0;
@@ -413,14 +413,14 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		newpsl->sl_max = count;
 		newpsl->sl_count = count - IP6_SFBLOCK;
 		if (psl) {
-			for (i = 0; i<psl->sl_count; i++)
+			for (i = 0; i < psl->sl_count; i++)
 				newpsl->sl_addr[i] = psl->sl_addr[i];
 			sock_kfree_s(sk, psl, IP6_SFLSIZE(psl->sl_max));
 		}
 		pmc->sflist = psl = newpsl;
 	}
 	rv = 1;	/* > 0 for insert logic below if sl_count is 0 */
-	for (i = 0; i<psl->sl_count; i++) {
+	for (i = 0; i < psl->sl_count; i++) {
 		rv = memcmp(&psl->sl_addr[i], source, sizeof(struct in6_addr));
 		if (rv == 0)
 			break;
@@ -496,7 +496,7 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 			goto done;
 		}
 		newpsl->sl_max = newpsl->sl_count = gsf->gf_numsrc;
-		for (i = 0; i<newpsl->sl_count; ++i) {
+		for (i = 0; i < newpsl->sl_count; ++i) {
 			struct sockaddr_in6 *psin6;
 
 			psin6 = (struct sockaddr_in6 *)&gsf->gf_slist[i];
@@ -588,7 +588,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	 * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
 	 * have the socket lock, so reading here is safe.
 	 */
-	for (i = 0; i<copycount; i++) {
+	for (i = 0; i < copycount; i++) {
 		struct sockaddr_in6 *psin6;
 		struct sockaddr_storage ss;
 
@@ -630,7 +630,7 @@ int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 	} else {
 		int i;
 
-		for (i = 0; i<psl->sl_count; i++) {
+		for (i = 0; i < psl->sl_count; i++) {
 			if (ipv6_addr_equal(&psl->sl_addr[i], src_addr))
 				break;
 		}
@@ -1056,7 +1056,7 @@ static int mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
 	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i = 0; i<nsrcs; i++) {
+		for (i = 0; i < nsrcs; i++) {
 			/* skip inactive filters */
 			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->mca_sfcount[MCAST_EXCLUDE] !=
@@ -1089,7 +1089,7 @@ static int mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i = 0; i<nsrcs; i++) {
+		for (i = 0; i < nsrcs; i++) {
 			if (ipv6_addr_equal(&srcs[i], &psf->sf_addr)) {
 				psf->sf_gsresp = 1;
 				scount++;
@@ -1873,7 +1873,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		pmc->mca_sfcount[sfmode]--;
 	}
 	err = 0;
-	for (i = 0; i<sfcount; i++) {
+	for (i = 0; i < sfcount; i++) {
 		int rv = ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 
 		changerec |= rv > 0;
@@ -2033,7 +2033,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!delta)
 		pmc->mca_sfcount[sfmode]++;
 	err = 0;
-	for (i = 0; i<sfcount; i++) {
+	for (i = 0; i < sfcount; i++) {
 		err = ip6_mc_add1_src(pmc, sfmode, &psfsrc[i]);
 		if (err)
 			break;
@@ -2043,7 +2043,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 
 		if (!delta)
 			pmc->mca_sfcount[sfmode]--;
-		for (j = 0; j<i; j++)
+		for (j = 0; j < i; j++)
 			ip6_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
 		struct ip6_sf_list *psf;
-- 
1.7.10
