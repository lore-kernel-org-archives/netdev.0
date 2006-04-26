From: Alex Davis <alex14641@yahoo.com>
Subject: Re: [PATCH] compile error in ieee80211_ioctl.c
Date: Wed, 26 Apr 2006 09:29:46 -0700 (PDT)
Message-ID: <20060426162946.38818.qmail@web50212.mail.yahoo.com>
References: <20060425211236.GC19116@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web50212.mail.yahoo.com ([206.190.39.176]:25683 "HELO
	web50212.mail.yahoo.com") by vger.kernel.org with SMTP
	id S964810AbWDZQ3r (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Apr 2006 12:29:47 -0400
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20060425211236.GC19116@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



--- "John W. Linville" <linville@tuxdriver.com> wrote:

> On Tue, Apr 25, 2006 at 02:04:50PM -0700, Alex Davis wrote:
> > Hello:
> > 
> > I sent this patch earlier and got no response, so I'm sending it again.
> > 
> > 
> > I cloned git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-dev.git
> > last night and got compile errors while compiling net/d80211/ieee80211_ioctl.c
> > into a module:
> 
> You need to address Randy's concerns as well.
> 
> Thanks,
> 
> John

Here is an updated patch which addresses Randy's issues. I'm currently running
this with no problems:

Signed-off-by: Alex Davis <alex14641@yahoo.com>

diff --git a/net/d80211/ieee80211_ioctl.c b/net/d80211/ieee80211_ioctl.c
index 42a7abe..1b14e6c 100644
--- a/net/d80211/ieee80211_ioctl.c
+++ b/net/d80211/ieee80211_ioctl.c
@@ -30,7 +30,7 @@ #include "aes_ccm.h"


 static int ieee80211_regdom = 0x10; /* FCC */
-MODULE_PARM(ieee80211_regdom, "i");
+module_param(ieee80211_regdom, int, 0666);
 MODULE_PARM_DESC(ieee80211_regdom, "IEEE 802.11 regulatory domain; 64=MKK");

 /*
@@ -40,7 +40,7 @@ MODULE_PARM_DESC(ieee80211_regdom, "IEEE
  * module.
  */
 static int ieee80211_japan_5ghz /* = 0 */;
-MODULE_PARM(ieee80211_japan_5ghz, "i");
+module_param(ieee80211_japan_5ghz, int, 0666);
 MODULE_PARM_DESC(ieee80211_japan_5ghz, "Vendor-updated firmware for 5 GHz");


> John W. Linville
> linville@tuxdriver.com
> 



I code, therefore I am

__________________________________________________
Do You Yahoo!?
Tired of spam?  Yahoo! Mail has the best spam protection around 
http://mail.yahoo.com 
