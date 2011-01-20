From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH 00/79] netfilter: netfilter update
Date: Thu, 20 Jan 2011 02:36:10 +0100 (CET)
Message-ID: <alpine.LNX.2.01.1101200235350.31108@obet.zrqbmnf.qr>
References: <1295464519-21763-1-git-send-email-kaber@trash.net> <20110119.135504.149816150.davem@davemloft.net> <20110119.165045.25148392.davem@davemloft.net> <4D378C3B.1020202@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:59659 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752369Ab1ATBgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Jan 2011 20:36:11 -0500
In-Reply-To: <4D378C3B.1020202@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Thursday 2011-01-20 02:13, Patrick McHardy wrote:
>> +header-y += xt_secmark.h
>> 
>> No active tree has a include/linux/netfilter/xt_secmark.h file.  Therefore
>> we end up with:
>> 
>> Did you mean xt_SECMARK.h (caps)?
>
>I guess so. Jan, please fix this up.

parent f5c88f56b35599ab9ff2d3398e0153e4cd4a4c82 (v2.6.37-3820-gf5c88f5)
commit 51c7fc9e4e086e4a145617945fdda92a8ae0290f
Author: Jan Engelhardt <jengelh@medozas.de>
Date:   Thu Jan 20 02:34:48 2011 +0100

netfilter: xtables: remove extraneous header that slipped in

Commit 0b8ad876275c74e4bfb6ec3150793f3c0ecfcee2 erroneously added
this.

Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
---
 include/linux/netfilter/Kbuild |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/include/linux/netfilter/Kbuild b/include/linux/netfilter/Kbuild
index fc4e0aa..89c0d1e 100644
--- a/include/linux/netfilter/Kbuild
+++ b/include/linux/netfilter/Kbuild
@@ -56,7 +56,6 @@ header-y += xt_rateest.h
 header-y += xt_realm.h
 header-y += xt_recent.h
 header-y += xt_sctp.h
-header-y += xt_secmark.h
 header-y += xt_socket.h
 header-y += xt_state.h
 header-y += xt_statistic.h
-- 
# Created with git-export-patch
