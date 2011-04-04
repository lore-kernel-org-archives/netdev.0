From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: [PATCH] MAINTAINERS: add entry for Xen network backend
Date: Mon, 4 Apr 2011 10:12:23 +0100
Message-ID: <1301908343.23887.54.camel@zakaz.uk.xensource.com>
References: <1301905567-7880-1-git-send-email-ian.campbell@citrix.com>
	 <20110404.020748.212408124.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xensource.com" <xen-devel@lists.xensource.com>,
	"akpm@linux-foundation.org" <akpm@linux-foundation.org>,
	"torvalds@linux-foundation.org" <torvalds@linux-foundation.org>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20110404.020748.212408124.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2011-04-04 at 10:07 +0100, David Miller wrote:
> From: Ian Campbell <ian.campbell@citrix.com>
> Date: Mon,  4 Apr 2011 09:26:07 +0100
> 
> > +XEN NETWORK BACKEND DRIVER
> > +M:	Ian Campbell <ian.campbell@citrix.com>
> > +L:	xen-devel@lists.xensource.com (moderated for non-subscribers)
> > +S:	Supported
> > +F:	drivers/net/xen-netback/*
> > +
> 
> To me there isn't much reason to have patch and other discussions
> about a network driver on a moderated XEN list (which the majority of
> core network developers are not subscribed to).
> 
> If anything, list both.  But not listing netdev is pretty pointless.

get_maintainer.pl lists both (due to the umbrella netdev entry) so I
didn't think it was required here also, I stand corrected.

8<-------------------------------------

>From 6c71610a1155eecc72f22529513bc130cfab3fe2 Mon Sep 17 00:00:00 2001
From: Ian Campbell <ian.campbell@citrix.com>
Date: Mon, 4 Apr 2011 09:15:29 +0100
Subject: [PATCH] MAINTAINERS: add entry for Xen network backend

Signed-off-by: Ian Campbell <ian.campbell@citrix.com>
Cc: netdev@vger.kernel.org
Cc: xen-devel@lists.xensource.com
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Linus Torvalds <torvalds@linux-foundation.org>
---
 MAINTAINERS |    7 +++++++
 1 files changed, 7 insertions(+), 0 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6b4b9cd..649600c 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -6916,6 +6916,13 @@ T:	git git://git.kernel.org/pub/scm/linux/kernel/git/mjg59/platform-drivers-x86.
 S:	Maintained
 F:	drivers/platform/x86
 
+XEN NETWORK BACKEND DRIVER
+M:	Ian Campbell <ian.campbell@citrix.com>
+L:	xen-devel@lists.xensource.com (moderated for non-subscribers)
+L:	netdev@vger.kernel.org
+S:	Supported
+F:	drivers/net/xen-netback/*
+
 XEN PCI SUBSYSTEM
 M:	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
 L:	xen-devel@lists.xensource.com (moderated for non-subscribers)
-- 
1.7.2.5
