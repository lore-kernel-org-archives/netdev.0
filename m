From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] d80211: use list_for_each_entry{,_safe}
Date: Thu, 31 Aug 2006 08:58:50 +0200
Message-ID: <1157007530.3065.0.camel@ux156>
References: <1156927420.4013.57.camel@ux156>
	 <20060830154322.GA18041@instant802.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Jiri Benc <jbenc@suse.cz>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:12008 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750766AbWHaG6Z
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Aug 2006 02:58:25 -0400
To: Jouni Malinen <jkm@devicescape.com>
In-Reply-To: <20060830154322.GA18041@instant802.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-08-30 at 08:43 -0700, Jouni Malinen wrote:

> Could you please separate cleanup parts (list_for_each changes) from
> functional changes (adding locking) to make it easier to review the
> patch?

Yeah, I guess I should do that.

> I would prefer not to hold spinlocks when calling registered callbacks
> from the hardware driver. At minimum, this would need to be documented
> very clearly to make sure that whoever is writing low-level drivers
> would be aware of this. In general, it would just be simpler if this can
> be avoided altogether.

You don't really have a choice here. The spinlock is the only thing that
protects the list... Not holding it is, umm, a bug :)

johannes
