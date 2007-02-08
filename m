From: Shinta Sugimoto <shinta@sfc.wide.ad.jp>
Subject: Fw: [PATCH 0/5] [XFRM,PFKEYV2]: MIGRATE support (take 2)
Date: Thu, 08 Feb 2007 09:42:00 +0900
Message-ID: <20070208093935.90CA.SHINTA@sfc.wide.ad.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sfc.wide.ad.jp ([203.178.142.146]:34030 "EHLO
	mail.sfc.wide.ad.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S965539AbXBHAmD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Feb 2007 19:42:03 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear David,

I noticed that I sent wrong version (not the newest one) of the
patch set by mistake.  I will re-post the patch set soon, so could
you please wait for that?  I am sorry for the confusion.

Regards,
Shinta

Forwarded by Shinta Sugimoto <shinta@sfc.wide.ad.jp>
----------------------- Original Message -----------------------
 From:    Shinta Sugimoto <shinta@sfc.wide.ad.jp>
 To:      netdev@vger.kernel.org
 Cc:      Francis Dupont <Francis.Dupont@point6.net>,
          Masahide Nakamura <nakam@linux-ipv6.org>,
          yoshfuji@linux-ipv6.org,
          usagi-core@linux-ipv6.org
 Date:    Wed, 07 Feb 2007 22:17:41 +0900
 Subject: [PATCH 0/5] [XFRM,PFKEYV2]: MIGRATE support (take 2)
----

Hello,

Let me send an updated version of patch set of MIGRATE support
for XFRM/PFKEYv2.  About a week ago, I sent a request for comments
for this patch set.  All the comments received were taken into
account.  In summary, the changes are as follow:

- replace alloc & memcpy with kmemdup
- remove unnecessary null-check
- fix bugs in handling protocol value for selector 
- add sanity check for handling MIGRATE message from PF_KEY socket
- some other minor changes

Please note that the patch set is against current net-2.6.21
tree and these changes are available in the branch named
"migrate-20070207-2131" at:

git://git.linux-ipv6.org/gitroot/shinta/net-2.6.21-migrate.git


Regards,
Shinta
-
To unsubscribe from this list: send the line "unsubscribe netdev" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
--------------------- Original Message Ends --------------------



