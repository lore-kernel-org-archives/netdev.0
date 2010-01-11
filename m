From: Joe Perches <joe@perches.com>
Subject: [PATCH V2] MAINTAINERS: netfilter - Document netfilter and
 netfilter-core lists purposes
Date: Mon, 11 Jan 2010 03:27:49 -0800
Message-ID: <1263209269.1907.61.camel@Joe-Laptop.home>
References: <cover.1262726222.git.joe@perches.com>
	 <bccf36219f3ea5a9b7565734bc87095bc986dbe0.1262726222.git.joe@perches.com>
	 <1262805798.1952.105.camel@Joe-Laptop.home>  <4B4B02BE.5060209@trash.net>
	 <1263208183.1907.50.camel@Joe-Laptop.home>  <4B4B0806.40801@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:1059 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751028Ab0AKL1v (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Jan 2010 06:27:51 -0500
In-Reply-To: <4B4B0806.40801@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, 2010-01-11 at 11:51 +0100, Patrick McHardy wrote:
> it's enough to CC netfilter-devel and optionally
> netdev on patches, netfilter and netfilter-core are unnecessary.
> On Mon, 2010-01-11 at 12:14 +0100, Patrick McHardy wrote:
> A comment stating the purpose of each list would be more appropriate.
> netfilter-devel is for developers and patches, netfilter is for users
> and netfilter-core is only meant to reach the coreteam privately.

Adding "subscribers-only" after the list address stops
scripts/get_maintainer.pl from including the address
unless --s is used.  Doesn't matter if the list really
is subscribers-only or not.

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/MAINTAINERS b/MAINTAINERS
index 745643b..ea5ddc8 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -3742,8 +3742,8 @@ P:	Harald Welte
 P:	Jozsef Kadlecsik
 M:	Patrick McHardy <kaber@trash.net>
 L:	netfilter-devel@vger.kernel.org
-L:	netfilter@vger.kernel.org
-L:	coreteam@netfilter.org
+L:	netfilter@vger.kernel.org	for user issues, not subscribers-only
+L:	coreteam@netfilter.org		for private emails, not subscribers-only
 W:	http://www.netfilter.org/
 W:	http://www.iptables.org/
 T:	git git://git.kernel.org/pub/scm/linux/kernel/git/kaber/nf-2.6.git


