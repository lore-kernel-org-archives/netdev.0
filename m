From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: more nl80211 stuff
Date: Thu, 14 Sep 2006 15:55:46 +0200
Message-ID: <1158242146.2936.70.camel@ux156>
References: <1158230812.2936.46.camel@ux156>
	 <1158241289.2634.7.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Jean Tourrilhes <jt@hpl.hp.com>,
	Jiri Benc <jbenc@suse.cz>,
	"James P. Ketrenos" <ipw2100-admin@linux.intel.com>,
	Mohamed Abbas <mabbas@linux.intel.com>,
	Ulrich Kunitz <kune@deine-taler.de>,
	Daniel Drake <dsd@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:12690 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1750782AbWINNzQ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 14 Sep 2006 09:55:16 -0400
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1158241289.2634.7.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2006-09-14 at 09:41 -0400, Dan Williams wrote:

> Can you describe a bit more what the scope of each of nl80211 and
> cfg80211 is?  Not sure I entirely understand the split and where the
> line is drawn.

Basically, I figured that cfg80211 is the kernel-internal interface and
nl80211 is just the primary userspace interface with WE compatibility
being a second one and possibly partial configurability in configfs
later. All drivers need to care about is cfg80211, hence I made the
split explicit.

johannes
