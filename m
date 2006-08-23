From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 16/18] d80211:  get rid of MICHAEL_MIC_HWACCEL define
Date: Wed, 23 Aug 2006 09:05:30 +0200
Message-ID: <1156316730.3629.7.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075202.538664376@sipsolutions.net>
	 <20060822210038.53ee194c@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:35038 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751441AbWHWHE4
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 03:04:56 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060822210038.53ee194c@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 21:00 +0200, Jiri Benc wrote:

> When you're touching this, could you #ifdef out wpa_test when
> CONFIG_HOSTAPD_WPA_TESTING is not defined? This could be a part of this
> patch.

I thought about it but deemed it too ugly. And wouldn't the compiler
optimize it away anyway? Thing is, it's used in tests, and having
#ifdefs within if (...) tests is hugely ugly.

johannes
