From: Jan Engelhardt <jengelh@medozas.de>
Subject: Re: [PATCH] ip: correctly report 802.15.4 link type
Date: Sun, 27 Jun 2010 09:01:38 +0200 (CEST)
Message-ID: <alpine.LSU.2.01.1006270901080.27605@obet.zrqbmnf.qr>
References: <7q2rynq4hva9nlyv9hdbhr26.1277596268239@email.android.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from borg.medozas.de ([188.40.89.202]:49578 "EHLO borg.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752698Ab0F0HBk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 27 Jun 2010 03:01:40 -0400
In-Reply-To: <7q2rynq4hva9nlyv9hdbhr26.1277596268239@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sunday 2010-06-27 01:51, Stephen Hemminger wrote:

>OK but long-term fix is to get rid of hardcoded table

With what will you be replacing it?


>>Up until now, the "hardwpan" devices were displayed as link/[804].
>>
>>Signed-off-by: Jan Engelhardt <jengelh@medozas.de>
>>---
>> lib/ll_types.c |    3 +++
>> 1 files changed, 3 insertions(+), 0 deletions(-)
>>
>>diff --git a/lib/ll_types.c b/lib/ll_types.c

>>index 846cdb0..1cc46b6 100644
>>--- a/lib/ll_types.c
>>+++ b/lib/ll_types.c
>>@@ -125,6 +125,9 @@ __PF(IEEE80211_PRISM,ieee802.11/prism)
>> #ifdef ARPHRD_IEEE80211_RADIOTAP
>> __PF(IEEE80211_RADIOTAP,ieee802.11/radiotap)
>> #endif
>>+#ifdef ARPHRD_IEEE802154
>>+__PF(IEEE802154, ieee802.15.4)
>>+#endif
>> #ifdef ARPHRD_NONE
>> __PF(NONE, none)
>> #endif
>>-- 
>>1.7.1
>>
>

