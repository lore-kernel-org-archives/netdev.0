From: =?ISO-8859-1?Q?S=E9rgio?= Monteiro Basto <sergiomb@netcabo.pt>
Subject: netfilter.diff resend
Date: Wed, 17 Mar 2004 11:20:51 +0000
Sender: linux-net-owner@vger.kernel.org
Message-ID: <1079522450.2630.5.camel@darkstar>
Reply-To: sergiomb@netcabo.pt
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-hABst8yhzjr25jBuO5Zy"
Return-path: <linux-net-owner@vger.kernel.org>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-hABst8yhzjr25jBuO5Zy
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 8bit

Hi

Can you apply this patch into kernel-2.4.2x ? for work with IP
Masquerade.

Reference:
http://lists.netfilter.org/pipermail/netfilter-devel/2002-November/009928.html

In begin, I apply this patch on redhat 7.3 box and thought this is a
specific problem of RedHat compiler, but I see exactly the same 
dependency dropped on a slackware-9.1 with kernel 2.4.25 and gcc3.3, do
me a favor and apply this mini patch.


On Wed, 2004-03-17 at 01:44, David S. Miller wrote: 
> On Tue, 16 Mar 2004 23:06:10 +0000
> Sérgio Monteiro Basto <sergiomb@netcabo.pt> wrote:
> 
> > Marcelo can you apply this patch? for work with IP Masquerade.
> 
> How come the netfilter people have not submitted this patch?
> I've never had any problems with the netfilter maintainers
> being puntual and sending me the patches that do need to be
> included.  So please contact Harald Welte and ask him to
> submit the patch if you think it's important.
> 
> Also, please use netdev@oss.sgi.com or linux-net@vger.kernel.org
> for networking patches and discussion, most net folks don't watch
> linux-kernel, thanks.
-- 
Sérgio M. B.

--=-hABst8yhzjr25jBuO5Zy
Content-Disposition: attachment; filename=netfilter.diff
Content-Type: text/x-patch; name=netfilter.diff; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit

--- 2.4.20/include/linux/netfilter_ipv4/ip_conntrack.h.orig	Sat May 31 23:22:01 2003
+++ 2.4.20+/include/linux/netfilter_ipv4/ip_conntrack.h	Sun Jun  1 00:11:03 2003
@@ -156,7 +156,8 @@
 	union ip_conntrack_expect_help help;
 };
 
-#include <linux/netfilter_ipv4/ip_conntrack_helper.h>
+struct ip_conntrack_helper;
+
 struct ip_conntrack
 {
 	/* Usage count in here is 1 for hash table/destruct timer, 1 per skb,

--=-hABst8yhzjr25jBuO5Zy--

