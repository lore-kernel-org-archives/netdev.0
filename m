From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] ieee80211: quiet TKIP and CCMP replay messages for
	identical TSCs
Date: Fri, 29 Sep 2006 09:41:01 +0200
Message-ID: <1159515661.2644.5.camel@ux156>
References: <4517FA78.mailH4P11L3ZE@lwfinger.net>
	 <20060928160240.GB9615@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:60317 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1161478AbWI2HkQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 03:40:16 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060928160240.GB9615@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-28 at 09:02 -0700, Jouni Malinen wrote:
> (and it should be fixed if it did not do its
> job correctly). 

Yup, that's actually the correct fix for this problem. ieee80211 doesn't
do any such thing afaict, probably because Intel's hardware does it
directly or something.

johannes
