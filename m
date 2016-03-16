From: Phil Sutter <phil@nwl.cc>
Subject: [iproute PATCH 1/8] doc/tc-filters.tex: Drop overly subjective paragraphs
Date: Wed, 16 Mar 2016 22:56:17 +0100
Message-ID: <1458165384-900-2-git-send-email-phil@nwl.cc>
References: <1458165384-900-1-git-send-email-phil@nwl.cc>
Cc: Jamal Hadi Salim <jhs@mojatatu.com>, netdev@vger.kernel.org,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Stephen Hemminger <shemming@brocade.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from orbyte.nwl.cc ([151.80.46.58]:54661 "EHLO mail.nwl.cc"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S966164AbcCPV5V (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Mar 2016 17:57:21 -0400
In-Reply-To: <1458165384-900-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Signed-off-by: Phil Sutter <phil@nwl.cc>
---
 doc/tc-filters.tex | 23 ++++-------------------
 1 file changed, 4 insertions(+), 19 deletions(-)

diff --git a/doc/tc-filters.tex b/doc/tc-filters.tex
index 59127d6672ed7..54cc0c9920ce2 100644
--- a/doc/tc-filters.tex
+++ b/doc/tc-filters.tex
@@ -18,10 +18,6 @@
 \date{January 2016}
 \maketitle
 
-TC, the Traffic Control utility, has been there for a very long time - forever
-in my humble perception. It is still (and has ever been if I'm not mistaken) the
-only tool to configure QoS in Linux.
-
 Standard practice when transmitting packets over a medium which may block (due
 to congestion, e.g.) is to use a queue which temporarily holds these packets. In
 Linux, this queueing approach is where QoS happens: A Queueing Discipline
@@ -496,21 +492,10 @@ kernel itself doesn't.
 
 \section*{Conclusion}
 
-My personal impression is that although the \cmd{tc} utility is an absolute
-necessity for anyone aiming at doing QoS in Linux professionally, there are way
-too many loose ends and trip wires present in it's environment. Contributing to
-this is the fact, that much of the non-essential functionality is redundantly
-available in netfilter. Another problem which adds weight to the first one is a
-general lack of documentation. Of course, there are many HOWTOs and guides in
-the internet, but since it's often not clear how up to date these are, I prefer
-the usual resources such as man or info pages. Surely nothing one couldn't fix
-in hindsight, but quality certainly suffers if the original author of the code
-does not or can not contribute to that.
-
-All that being said, once the steep learning curve has been mastered, the
-conglomerate of (classful) qdiscs, filters and actions provides a highly
-sophisticated and flexible infrastructure to perform QoS, which plays nicely
-along with routing and firewalling setups.
+Once the steep learning curve has been mastered, the conglomerate of (classful)
+qdiscs, filters and actions provides a highly sophisticated and flexible
+infrastructure to perform QoS, which plays nicely along with routing and
+firewalling setups.
 
 
 \section*{Further Reading}
-- 
2.7.2
