From: Joe Perches <joe@perches.com>
Subject: [PATCH V3] MAINTAINERS: Document list types, add "A:" section
 type, update NETFILTER
Date: Tue, 12 Jan 2010 10:46:34 -0800
Message-ID: <1263321994.25973.15.camel@Joe-Laptop.home>
References: <cover.1262726222.git.joe@perches.com>
	 <bccf36219f3ea5a9b7565734bc87095bc986dbe0.1262726222.git.joe@perches.com>
	 <1262805798.1952.105.camel@Joe-Laptop.home>  <4B4B02BE.5060209@trash.net>
	 <1263208183.1907.50.camel@Joe-Laptop.home>  <4B4B0806.40801@trash.net>
	 <1263209269.1907.61.camel@Joe-Laptop.home>
	 <alpine.LSU.2.01.1001111229460.26235@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, linux-kernel@vger.kernel.org,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Jan Engelhardt <jengelh@medozas.de>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.LSU.2.01.1001111229460.26235@obet.zrqbmnf.qr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2010-01-11 at 12:31 +0100, Jan Engelhardt wrote:
> This is a little stab-through-the-back -
> rather than "subscribers-only", I'd use "subscriber-free" or FFA,
> or just leave it blank and use "subscribers-only" instead
> for these.

Here's another option:

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 745643b..8abf3be 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -69,7 +69,20 @@ Descriptions of section entries:
 
 	P: Person (obsolete)
 	M: Mail patches to: FullName <address@domain>
-	L: Mailing list that is relevant to this area
+	L: Mailing list that should receive patches, bug reports or
+	   developer questions.
+	   Mailing lists can be one of:
+	   (open list):	the default, unmarked case
+			Subscription to the list is not required, but emails
+			may be rejected by spam filters without notification.
+	   (moderated for non-subscribers):
+			emails from non-subscribers are actively filtered
+			and may be arbitrarily delayed or rejected without
+			notification if off-topic.  Upon receipt of the email,
+			a moderation notification email may be automatically
+			sent by the list manager.
+	   (subscribers-only):
+			emails from non-subscribers are not accepted.
 	W: Web-page with status/info
 	T: SCM tree type and location.  Type is one of: git, hg, quilt, stgit.
 	S: Status, one of the following:
@@ -102,6 +115,7 @@ Descriptions of section entries:
 	      matches patches or files that contain one or more of the words
 	      printk, pr_info or pr_err
 	   One regex pattern per line.  Multiple K: lines acceptable.
+	A: Additional useful unstructured information.
 
 Note: For the hard of thinking, this list is meant to remain in alphabetical
 order. If you could add yourselves to it in alphabetical order that would be
@@ -3742,8 +3756,8 @@ P:	Harald Welte
 P:	Jozsef Kadlecsik
 M:	Patrick McHardy <kaber@trash.net>
 L:	netfilter-devel@vger.kernel.org
-L:	netfilter@vger.kernel.org
-L:	coreteam@netfilter.org
+A:	netfilter@vger.kernel.org	(email list for user issues)
+A:	coreteam@netfilter.org		(private emails to core developers)
 W:	http://www.netfilter.org/
 W:	http://www.iptables.org/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git


