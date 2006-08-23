From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 08/18] d80211:  clean up exports
Date: Wed, 23 Aug 2006 09:01:43 +0200
Message-ID: <1156316503.3629.1.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075200.277082970@sipsolutions.net>
	 <20060822164436.GG13240@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:7902 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1751436AbWHWHBs
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 03:01:48 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060822164436.GG13240@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-08-22 at 09:44 -0700, Jouni Malinen wrote:

> Moving the EXPORT_SYMBOL definitions sounds good, but I would like to
> keep changes between EXPORT_SYMBOL and EXPORT_SYMBOL_GPL separate from
> this kind of cleanup. In addition, I'm not personally a huge fan of the
> EXPORT_SYMBOL_GPL in the first place since I believe the GPL should
> cover this without additional changes in the source code. In other
> words, I would prefer that the EXPORT_SYMBOL would not be changed to
> EXPORT_SYMBOL_GPL here.

I just intended making it _GPL as an additional deterrent since you
practically need the internal ieee80211_i.h header for any kind of rate
control algorithm. I'm fine with dropping them, however.

johannes
