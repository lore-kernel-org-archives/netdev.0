From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: cfg80211 take 7
Date: Fri, 06 Oct 2006 17:07:49 +0200
Message-ID: <1160147269.2715.88.camel@ux156>
References: <1160146790.2715.82.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:41648 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932431AbWJFPG7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Oct 2006 11:06:59 -0400
To: netdev <netdev@vger.kernel.org>
In-Reply-To: <1160146790.2715.82.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Maybe this time it'll take the announcement too?
---
I have
 * addressed Dan's comments about naming a few things and
   also fixed the problems he pointed out
 * moved wext from net/core/wireless.c to net/wireless/wext-old.c
 * added compat hunking for WE to cfg80211, finally completely
   separating the userspace interface and the internal interface
 * made it possible to port drivers to cfg80211 call by call!  
 * fixed a bug with locking in core.c

I have not
 * added get_scan
 * added event notification

Have fun. Oh, I can put this into a git tree too if you think that'd be
useful for further collaboration. However, I'm thinking that wireless-dev
could also be used since this doesn't really break anything, it just adds
new code that might not be in use yet, but should be fairly good to use  
should anyone want that.

I guess what I'm trying to say with that is that there's no way I can finish
this all by myself, I also need sleep sometimes ;) I thank everyone for
their review and suppose that more people read it than commented (which is
probably a good thing). Hopefully I can motivate you with these patches that
should ease migration to actually help with code as well :)

johannes
