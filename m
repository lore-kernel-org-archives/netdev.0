From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] mac80211: minstrels: spare numerous useless calls to
 get_random_bytes
Date: Wed, 13 Nov 2013 19:34:06 +0100
Message-ID: <1384367646.14578.24.camel@jlt4.sipsolutions.net>
References: <1384336459-5322-1-git-send-email-karl.beldan@gmail.com>
	 (sfid-20131113_105448_249049_106CA6AF)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Felix Fietkau <nbd@openwrt.org>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	netdev@vger.kernel.org, Karl Beldan <karl.beldan@rivierawaves.com>
To: Karl Beldan <karl.beldan@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:45263 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759415Ab3KMSeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 13:34:10 -0500
In-Reply-To: <1384336459-5322-1-git-send-email-karl.beldan@gmail.com> (sfid-20131113_105448_249049_106CA6AF)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-11-13 at 10:54 +0100, Karl Beldan wrote:
> From: Karl Beldan <karl.beldan@rivierawaves.com>
> 
> ATM, only the first array value returned by get_random_bytes is used.
> This change moves the call to get_random_bytes from the nested loop it
> is in to its parent.
> While at it, replace get_random_bytes with prandom_bytes since PRNs are
> way enough for the selection process.
> After this, minstrel_ht reclaims 80 PR-bytes instead of 640 R-bytes.

Applied.

johannes
