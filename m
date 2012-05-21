From: Jeffrin Jose <ahiliation@yahoo.co.in>
Subject: [PATCH 2/4]net:ipv6:fixed spacing issues for = operator
Date: Tue, 22 May 2012 00:34:03 +0530
Message-ID: <1337627043-3314-1-git-send-email-ahiliation@yahoo.co.in>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	ahiliation@yahoo.co.in
To: davem@davemloft.net, edumazet@google.com, loke.chetan@gmail.com,
	herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Fixed spacing issues related to = operator
found in net/ipv6/mcast.c by checkpatch.pl tool

Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
---
 net/ipv6/mcast.c |   94 +++++++++++++++++++++++++++---------------------------
 1 file changed, 47 insertions(+), 47 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 8f7eee9..66235a0 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -369,7 +369,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		if (!psl)
 			goto done;	/* err = -EADDRNOTAVAIL */
 		rv = !0;
-		for (i=0; i<psl->sl_count; i++) {
+		for (i = 0; i<psl->sl_count; i++) {
 			rv = memcmp(&psl->sl_addr[i], source,
 				sizeof(struct in6_addr));
 			if (rv == 0)
@@ -387,7 +387,7 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		/* update the interface filter */
 		ip6_mc_del_src(idev, group, omode, 1, source, 1);
 
-		for (j=i+1; j<psl->sl_count; j++)
+		for (j = i+1; j<psl->sl_count; j++)
 			psl->sl_addr[j-1] = psl->sl_addr[j];
 		psl->sl_count--;
 		err = 0;
@@ -413,21 +413,21 @@ int ip6_mc_source(int add, int omode, struct sock *sk,
 		newpsl->sl_max = count;
 		newpsl->sl_count = count - IP6_SFBLOCK;
 		if (psl) {
-			for (i=0; i<psl->sl_count; i++)
+			for (i = 0; i<psl->sl_count; i++)
 				newpsl->sl_addr[i] = psl->sl_addr[i];
 			sock_kfree_s(sk, psl, IP6_SFLSIZE(psl->sl_max));
 		}
 		pmc->sflist = psl = newpsl;
 	}
 	rv = 1;	/* > 0 for insert logic below if sl_count is 0 */
-	for (i=0; i<psl->sl_count; i++) {
+	for (i = 0; i<psl->sl_count; i++) {
 		rv = memcmp(&psl->sl_addr[i], source, sizeof(struct in6_addr));
 		if (rv == 0)
 			break;
 	}
 	if (rv == 0)		/* address already there is an error */
 		goto done;
-	for (j=psl->sl_count-1; j>=i; j--)
+	for (j = psl->sl_count-1; j>=i; j--)
 		psl->sl_addr[j+1] = psl->sl_addr[j];
 	psl->sl_addr[i] = *source;
 	psl->sl_count++;
@@ -496,7 +496,7 @@ int ip6_mc_msfilter(struct sock *sk, struct group_filter *gsf)
 			goto done;
 		}
 		newpsl->sl_max = newpsl->sl_count = gsf->gf_numsrc;
-		for (i=0; i<newpsl->sl_count; ++i) {
+		for (i = 0; i<newpsl->sl_count; ++i) {
 			struct sockaddr_in6 *psin6;
 
 			psin6 = (struct sockaddr_in6 *)&gsf->gf_slist[i];
@@ -588,7 +588,7 @@ int ip6_mc_msfget(struct sock *sk, struct group_filter *gsf,
 	 * on ipv6_sk_mc_lock and a write lock on pmc->sflock. We
 	 * have the socket lock, so reading here is safe.
 	 */
-	for (i=0; i<copycount; i++) {
+	for (i = 0; i<copycount; i++) {
 		struct sockaddr_in6 *psin6;
 		struct sockaddr_storage ss;
 
@@ -630,7 +630,7 @@ int inet6_mc_check(struct sock *sk, const struct in6_addr *mc_addr,
 	} else {
 		int i;
 
-		for (i=0; i<psl->sl_count; i++) {
+		for (i = 0; i<psl->sl_count; i++) {
 			if (ipv6_addr_equal(&psl->sl_addr[i], src_addr))
 				break;
 		}
@@ -736,7 +736,7 @@ static void mld_add_delrec(struct inet6_dev *idev, struct ifmcaddr6 *im)
 		pmc->mca_tomb = im->mca_tomb;
 		pmc->mca_sources = im->mca_sources;
 		im->mca_tomb = im->mca_sources = NULL;
-		for (psf=pmc->mca_sources; psf; psf=psf->sf_next)
+		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = pmc->mca_crcount;
 	}
 	spin_unlock_bh(&im->mca_lock);
@@ -754,7 +754,7 @@ static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *pmca)
 
 	spin_lock_bh(&idev->mc_lock);
 	pmc_prev = NULL;
-	for (pmc=idev->mc_tomb; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_tomb; pmc; pmc = pmc->next) {
 		if (ipv6_addr_equal(&pmc->mca_addr, pmca))
 			break;
 		pmc_prev = pmc;
@@ -768,7 +768,7 @@ static void mld_del_delrec(struct inet6_dev *idev, const struct in6_addr *pmca)
 	spin_unlock_bh(&idev->mc_lock);
 
 	if (pmc) {
-		for (psf=pmc->mca_tomb; psf; psf=psf_next) {
+		for (psf = pmc->mca_tomb; psf; psf = psf_next) {
 			psf_next = psf->sf_next;
 			kfree(psf);
 		}
@@ -795,14 +795,14 @@ static void mld_clear_delrec(struct inet6_dev *idev)
 
 	/* clear dead sources, too */
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		struct ip6_sf_list *psf, *psf_next;
 
 		spin_lock_bh(&pmc->mca_lock);
 		psf = pmc->mca_tomb;
 		pmc->mca_tomb = NULL;
 		spin_unlock_bh(&pmc->mca_lock);
-		for (; psf; psf=psf_next) {
+		for (; psf; psf = psf_next) {
 			psf_next = psf->sf_next;
 			kfree(psf);
 		}
@@ -891,7 +891,7 @@ int __ipv6_dev_mc_dec(struct inet6_dev *idev, const struct in6_addr *addr)
 	struct ifmcaddr6 *ma, **map;
 
 	write_lock_bh(&idev->lock);
-	for (map = &idev->mc_list; (ma=*map) != NULL; map = &ma->next) {
+	for (map = &idev->mc_list; (ma = *map) != NULL; map = &ma->next) {
 		if (ipv6_addr_equal(&ma->mca_addr, addr)) {
 			if (--ma->mca_users == 0) {
 				*map = ma->next;
@@ -969,7 +969,7 @@ int ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 	idev = __in6_dev_get(dev);
 	if (idev) {
 		read_lock_bh(&idev->lock);
-		for (mc = idev->mc_list; mc; mc=mc->next) {
+		for (mc = idev->mc_list; mc; mc = mc->next) {
 			if (ipv6_addr_equal(&mc->mca_addr, group))
 				break;
 		}
@@ -978,7 +978,7 @@ int ipv6_chk_mcast_addr(struct net_device *dev, const struct in6_addr *group,
 				struct ip6_sf_list *psf;
 
 				spin_lock_bh(&mc->mca_lock);
-				for (psf=mc->mca_sources;psf;psf=psf->sf_next) {
+				for (psf = mc->mca_sources;psf;psf = psf->sf_next) {
 					if (ipv6_addr_equal(&psf->sf_addr, src_addr))
 						break;
 				}
@@ -1053,10 +1053,10 @@ static int mld_xmarksources(struct ifmcaddr6 *pmc, int nsrcs,
 	int i, scount;
 
 	scount = 0;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i=0; i<nsrcs; i++) {
+		for (i = 0; i<nsrcs; i++) {
 			/* skip inactive filters */
 			if (psf->sf_count[MCAST_INCLUDE] ||
 			    pmc->mca_sfcount[MCAST_EXCLUDE] !=
@@ -1086,10 +1086,10 @@ static int mld_marksources(struct ifmcaddr6 *pmc, int nsrcs,
 	/* mark INCLUDE-mode sources */
 
 	scount = 0;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (scount == nsrcs)
 			break;
-		for (i=0; i<nsrcs; i++) {
+		for (i = 0; i<nsrcs; i++) {
 			if (ipv6_addr_equal(&srcs[i], &psf->sf_addr)) {
 				psf->sf_gsresp = 1;
 				scount++;
@@ -1192,13 +1192,13 @@ int igmp6_event_query(struct sk_buff *skb)
 
 	read_lock_bh(&idev->lock);
 	if (group_type == IPV6_ADDR_ANY) {
-		for (ma = idev->mc_list; ma; ma=ma->next) {
+		for (ma = idev->mc_list; ma; ma = ma->next) {
 			spin_lock_bh(&ma->mca_lock);
 			igmp6_group_queried(ma, max_delay);
 			spin_unlock_bh(&ma->mca_lock);
 		}
 	} else {
-		for (ma = idev->mc_list; ma; ma=ma->next) {
+		for (ma = idev->mc_list; ma; ma = ma->next) {
 			if (!ipv6_addr_equal(group, &ma->mca_addr))
 				continue;
 			spin_lock_bh(&ma->mca_lock);
@@ -1262,7 +1262,7 @@ int igmp6_event_report(struct sk_buff *skb)
 	 */
 
 	read_lock_bh(&idev->lock);
-	for (ma = idev->mc_list; ma; ma=ma->next) {
+	for (ma = idev->mc_list; ma; ma = ma->next) {
 		if (ipv6_addr_equal(&ma->mca_addr, &mld->mld_mca)) {
 			spin_lock(&ma->mca_lock);
 			if (del_timer(&ma->mca_timer))
@@ -1326,7 +1326,7 @@ mld_scount(struct ifmcaddr6 *pmc, int type, int gdeleted, int sdeleted)
 	struct ip6_sf_list *psf;
 	int scount = 0;
 
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (!is_in(pmc, psf, type, gdeleted, sdeleted))
 			continue;
 		scount++;
@@ -1510,7 +1510,7 @@ static struct sk_buff *add_grec(struct sk_buff *skb, struct ifmcaddr6 *pmc,
 	}
 	first = 1;
 	psf_prev = NULL;
-	for (psf=*psf_list; psf; psf=psf_next) {
+	for (psf = *psf_list; psf; psf = psf_next) {
 		struct in6_addr *psrc;
 
 		psf_next = psf->sf_next;
@@ -1589,7 +1589,7 @@ static void mld_send_report(struct inet6_dev *idev, struct ifmcaddr6 *pmc)
 
 	if (!pmc) {
 		read_lock_bh(&idev->lock);
-		for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+		for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 			if (pmc->mca_flags & MAF_NOREPORT)
 				continue;
 			spin_lock_bh(&pmc->mca_lock);
@@ -1622,7 +1622,7 @@ static void mld_clear_zeros(struct ip6_sf_list **ppsf)
 	struct ip6_sf_list *psf_prev, *psf_next, *psf;
 
 	psf_prev = NULL;
-	for (psf=*ppsf; psf; psf = psf_next) {
+	for (psf = *ppsf; psf; psf = psf_next) {
 		psf_next = psf->sf_next;
 		if (psf->sf_crcount == 0) {
 			if (psf_prev)
@@ -1646,7 +1646,7 @@ static void mld_send_cr(struct inet6_dev *idev)
 
 	/* deleted MCA's */
 	pmc_prev = NULL;
-	for (pmc=idev->mc_tomb; pmc; pmc=pmc_next) {
+	for (pmc = idev->mc_tomb; pmc; pmc = pmc_next) {
 		pmc_next = pmc->next;
 		if (pmc->mca_sfmode == MCAST_INCLUDE) {
 			type = MLD2_BLOCK_OLD_SOURCES;
@@ -1679,7 +1679,7 @@ static void mld_send_cr(struct inet6_dev *idev)
 	spin_unlock(&idev->mc_lock);
 
 	/* change recs */
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		spin_lock_bh(&pmc->mca_lock);
 		if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
 			type = MLD2_BLOCK_OLD_SOURCES;
@@ -1812,7 +1812,7 @@ static int ip6_mc_del1_src(struct ifmcaddr6 *pmc, int sfmode,
 	int rv = 0;
 
 	psf_prev = NULL;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
 			break;
 		psf_prev = psf;
@@ -1853,7 +1853,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!idev)
 		return -ENODEV;
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		if (ipv6_addr_equal(pmca, &pmc->mca_addr))
 			break;
 	}
@@ -1873,7 +1873,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		pmc->mca_sfcount[sfmode]--;
 	}
 	err = 0;
-	for (i=0; i<sfcount; i++) {
+	for (i = 0; i<sfcount; i++) {
 		int rv = ip6_mc_del1_src(pmc, sfmode, &psfsrc[i]);
 
 		changerec |= rv > 0;
@@ -1889,7 +1889,7 @@ static int ip6_mc_del_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 		pmc->mca_sfmode = MCAST_INCLUDE;
 		pmc->mca_crcount = idev->mc_qrv;
 		idev->mc_ifc_count = pmc->mca_crcount;
-		for (psf=pmc->mca_sources; psf; psf = psf->sf_next)
+		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
 		mld_ifc_event(pmc->idev);
 	} else if (sf_setstate(pmc) || changerec)
@@ -1908,7 +1908,7 @@ static int ip6_mc_add1_src(struct ifmcaddr6 *pmc, int sfmode,
 	struct ip6_sf_list *psf, *psf_prev;
 
 	psf_prev = NULL;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (ipv6_addr_equal(&psf->sf_addr, psfsrc))
 			break;
 		psf_prev = psf;
@@ -1933,7 +1933,7 @@ static void sf_markstate(struct ifmcaddr6 *pmc)
 	struct ip6_sf_list *psf;
 	int mca_xcount = pmc->mca_sfcount[MCAST_EXCLUDE];
 
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next)
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 		if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
 			psf->sf_oldin = mca_xcount ==
 				psf->sf_count[MCAST_EXCLUDE] &&
@@ -1950,7 +1950,7 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 	int new_in, rv;
 
 	rv = 0;
-	for (psf=pmc->mca_sources; psf; psf=psf->sf_next) {
+	for (psf = pmc->mca_sources; psf; psf = psf->sf_next) {
 		if (pmc->mca_sfcount[MCAST_EXCLUDE]) {
 			new_in = mca_xcount == psf->sf_count[MCAST_EXCLUDE] &&
 				!psf->sf_count[MCAST_INCLUDE];
@@ -1960,8 +1960,8 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 			if (!psf->sf_oldin) {
 				struct ip6_sf_list *prev = NULL;
 
-				for (dpsf=pmc->mca_tomb; dpsf;
-				     dpsf=dpsf->sf_next) {
+				for (dpsf = pmc->mca_tomb; dpsf;
+				     dpsf = dpsf->sf_next) {
 					if (ipv6_addr_equal(&dpsf->sf_addr,
 					    &psf->sf_addr))
 						break;
@@ -1983,7 +1983,7 @@ static int sf_setstate(struct ifmcaddr6 *pmc)
 			 * add or update "delete" records if an active filter
 			 * is now inactive
 			 */
-			for (dpsf=pmc->mca_tomb; dpsf; dpsf=dpsf->sf_next)
+			for (dpsf = pmc->mca_tomb; dpsf; dpsf = dpsf->sf_next)
 				if (ipv6_addr_equal(&dpsf->sf_addr,
 				    &psf->sf_addr))
 					break;
@@ -2017,7 +2017,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!idev)
 		return -ENODEV;
 	read_lock_bh(&idev->lock);
-	for (pmc=idev->mc_list; pmc; pmc=pmc->next) {
+	for (pmc = idev->mc_list; pmc; pmc = pmc->next) {
 		if (ipv6_addr_equal(pmca, &pmc->mca_addr))
 			break;
 	}
@@ -2033,7 +2033,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 	if (!delta)
 		pmc->mca_sfcount[sfmode]++;
 	err = 0;
-	for (i=0; i<sfcount; i++) {
+	for (i = 0; i<sfcount; i++) {
 		err = ip6_mc_add1_src(pmc, sfmode, &psfsrc[i]);
 		if (err)
 			break;
@@ -2043,7 +2043,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 
 		if (!delta)
 			pmc->mca_sfcount[sfmode]--;
-		for (j=0; j<i; j++)
+		for (j = 0; j<i; j++)
 			ip6_mc_del1_src(pmc, sfmode, &psfsrc[j]);
 	} else if (isexclude != (pmc->mca_sfcount[MCAST_EXCLUDE] != 0)) {
 		struct ip6_sf_list *psf;
@@ -2057,7 +2057,7 @@ static int ip6_mc_add_src(struct inet6_dev *idev, const struct in6_addr *pmca,
 
 		pmc->mca_crcount = idev->mc_qrv;
 		idev->mc_ifc_count = pmc->mca_crcount;
-		for (psf=pmc->mca_sources; psf; psf = psf->sf_next)
+		for (psf = pmc->mca_sources; psf; psf = psf->sf_next)
 			psf->sf_crcount = 0;
 		mld_ifc_event(idev);
 	} else if (sf_setstate(pmc))
@@ -2071,12 +2071,12 @@ static void ip6_mc_clear_src(struct ifmcaddr6 *pmc)
 {
 	struct ip6_sf_list *psf, *nextpsf;
 
-	for (psf=pmc->mca_tomb; psf; psf=nextpsf) {
+	for (psf = pmc->mca_tomb; psf; psf = nextpsf) {
 		nextpsf = psf->sf_next;
 		kfree(psf);
 	}
 	pmc->mca_tomb = NULL;
-	for (psf=pmc->mca_sources; psf; psf=nextpsf) {
+	for (psf = pmc->mca_sources; psf; psf = nextpsf) {
 		nextpsf = psf->sf_next;
 		kfree(psf);
 	}
@@ -2223,7 +2223,7 @@ void ipv6_mc_down(struct inet6_dev *idev)
 	if (del_timer(&idev->mc_gq_timer))
 		__in6_dev_put(idev);
 
-	for (i = idev->mc_list; i; i=i->next)
+	for (i = idev->mc_list; i; i = i->next)
 		igmp6_group_dropped(i);
 	read_unlock_bh(&idev->lock);
 
@@ -2240,7 +2240,7 @@ void ipv6_mc_up(struct inet6_dev *idev)
 	/* Install multicast list, except for all-nodes (already installed) */
 
 	read_lock_bh(&idev->lock);
-	for (i = idev->mc_list; i; i=i->next)
+	for (i = idev->mc_list; i; i = i->next)
 		igmp6_group_added(i);
 	read_unlock_bh(&idev->lock);
 }
-- 
1.7.10
