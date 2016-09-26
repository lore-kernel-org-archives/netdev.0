From: Joe Perches <joe@perches.com>
Subject: Re: hostap: Delete an unnecessary jump label in
 prism2_ioctl_priv_hostapd()
Date: Mon, 26 Sep 2016 11:18:05 -0700
Message-ID: <1474913885.2238.19.camel@perches.com>
References: <65ed528f-7ec5-a0f2-6219-3e63a78ca0ee@users.sourceforge.net>
         <20160926150656.213D961568@smtp.codeaurora.org>
         <88d5023a-9a59-ab36-8c6c-a146cae803b5@users.sourceforge.net>
         <874m52zgjy.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        Jouni Malinen <j@w1.fi>, LKML <linux-kernel@vger.kernel.org>,
        kernel-janitors@vger.kernel.org,
        Julia Lawall <julia.lawall@lip6.fr>
To: Kalle Valo <kvalo@codeaurora.org>,
        SF Markus Elfring <elfring@users.sourceforge.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0162.hostedemail.com ([216.40.44.162]:50625 "EHLO
        smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1162961AbcIZSSJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 14:18:09 -0400
In-Reply-To: <874m52zgjy.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-09-26 at 21:01 +0300, Kalle Valo wrote:
> hostap is an obsolete driver, it's waste of time doing style fixes to it
> as nobody maintains it anymore.

Dunno know if Jouni is still maintaining this at all
but maybe a MAINTAINERS update to mark it obsolete so
checkpatch warns on unnecessary changes.
---
 MAINTAINERS | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 6e0a912c3b13..ff293e70fae6 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -5722,7 +5722,7 @@ M:	Jouni Malinen 
 L:	hostap@shmoo.com (subscribers-only)
 L:	linux-wireless@vger.kernel.org
 W:	http://hostap.epitest.fi/
-S:	Maintained
+S:	Maintained / Obsolete
 F:	drivers/net/wireless/intersil/hostap/
 
 HP COMPAQ TC1100 TABLET WMI EXTRAS DRIVER
