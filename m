From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ieee80211: quiet TKIP and CCMP replay messages for
	identical TSCs
Date: Tue, 26 Sep 2006 09:44:04 +0200
Message-ID: <1159256644.2782.3.camel@ux156>
References: <4517FA78.mailH4P11L3ZE@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:43491 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750730AbWIZHnT
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Sep 2006 03:43:19 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <4517FA78.mailH4P11L3ZE@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-09-25 at 10:49 -0500, Larry Finger wrote:
> When using TKIP and CCMP for wireless encryption with ieee80211, the logs get filled with useless
> replay messages where the previous and received TSC are identical. This change deletes
> the log message for this case, but still prints the message when there are major differences
> in the TSC's.

Hey, that seems like a good idea to get rid of the messages no one wants
to see (in the retransmit case) but still warn if someone is really
messing with it.

Acked-by: Johannes Berg <johannes@sipsolutions.net>

johannes
