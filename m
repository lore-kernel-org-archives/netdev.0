From: Joe Perches <joe@perches.com>
Subject: [PATCH] REPORTING-BUGS: Add get_maintainer.pl blurb
Date: Fri, 07 Aug 2009 10:01:55 -0700
Message-ID: <1249664515.3467.83.camel@Joe-Laptop.home>
References: <20090618183738.662f7ef1@emcraft.com>
	 <20090807153106.335b1b8f@emcraft.com>
	 <20090807.090353.191304972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: sposelenov@emcraft.com, linux-kernel@vger.kernel.org,
	Andrew Morton <akpm@linux-foundation.org>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754402AbZHGRCI@vger.kernel.org>
In-Reply-To: <20090807.090353.191304972.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Joe Perches <joe@perches.com>

diff --git a/REPORTING-BUGS b/REPORTING-BUGS
index ab0c566..55a6074 100644
--- a/REPORTING-BUGS
+++ b/REPORTING-BUGS
@@ -15,7 +15,10 @@ worry too much about getting the wrong person. If you are unsure send it
 to the person responsible for the code relevant to what you were doing.
 If it occurs repeatably try and describe how to recreate it. That is
 worth even more than the oops itself.  The list of maintainers and
-mailing lists is in the MAINTAINERS file in this directory.
+mailing lists is in the MAINTAINERS file in this directory.  If you
+know the file name that causes the problem you can use the following
+command in this directory to find some of the maintainers of that file:
+     perl scripts/get_maintainer.pl -f <filename>
 
       If it is a security bug, please copy the Security Contact listed
 in the MAINTAINERS file.  They can help coordinate bugfix and disclosure.
