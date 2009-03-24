From: Patrick McHardy <kaber@trash.net>
Subject: netfilter 20/41: install missing headers
Date: Tue, 24 Mar 2009 15:03:33 +0100 (MET)
Message-ID: <20090324140329.31401.96490.sendpatchset@x2.localnet>
References: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Cc: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
	netfilter-devel@vger.kernel.org
To: davem@davemloft.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20090324140302.31401.37732.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

commit d060ffc1840e37100628f520e66600c5ae483b44
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Tue Feb 24 15:23:58 2009 +0100

    netfilter: install missing headers
    
    iptables imports headers from (the unifdefed headers of a)
    kernel tree, but some headers happened to not be installed.
    
    Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
    Signed-off-by: Patrick McHardy <kaber@trash.net>

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index deeaee5..947b47d 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -14,8 +14,11 @@ header-y += xt_NFQUEUE.h
 header-y += xt_RATEEST.h
 header-y += xt_SECMARK.h
 header-y += xt_TCPMSS.h
+header-y += xt_TCPOPTSTRIP.h
+header-y += xt_TPROXY.h
 header-y += xt_comment.h
 header-y += xt_connbytes.h
+header-y += xt_connlimit.h
 header-y += xt_connmark.h
 header-y += xt_conntrack.h
 header-y += xt_dccp.h
@@ -31,6 +34,7 @@ header-y += xt_mark.h
 header-y += xt_multiport.h
 header-y += xt_owner.h
 header-y += xt_pkttype.h
+header-y += xt_quota.h
 header-y += xt_rateest.h
 header-y += xt_realm.h
 header-y += xt_recent.h
@@ -40,6 +44,8 @@ header-y += xt_statistic.h
 header-y += xt_string.h
 header-y += xt_tcpmss.h
 header-y += xt_tcpudp.h
+header-y += xt_time.h
+header-y += xt_u32.h
 
 unifdef-y += nf_conntrack_common.h
 unifdef-y += nf_conntrack_ftp.h
diff --git a/include/linux/netfilter_ipv6/Kbuild b/include/linux/netfilter_ipv6/Kbuild
index 8887a5f..aca4bd1 100644
--- a/include/linux/netfilter_ipv6/Kbuild
+++ b/include/linux/netfilter_ipv6/Kbuild
@@ -11,6 +11,7 @@ header-y += ip6t_length.h
 header-y += ip6t_limit.h
 header-y += ip6t_mac.h
 header-y += ip6t_mark.h
+header-y += ip6t_mh.h
 header-y += ip6t_multiport.h
 header-y += ip6t_opts.h
 header-y += ip6t_owner.h
