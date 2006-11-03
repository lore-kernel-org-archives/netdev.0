From: "Johannes Berg" <johannes@sipsolutions.net>
Subject: Re: [PATCH 0/6] rework d80211 cookie pointer
Date: Fri, 3 Nov 2006 20:08:13 +0100 (CET)
Message-ID: <19467.82.113.121.16.1162580893.squirrel@secure.sipsolutions.net>
References: <20061102223854.692274000@sipsolutions.net>>
    <200611031404.32926.flamingice@sourmilk.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "Jiri Benc" <jbenc@suse.cz>, netdev@vger.kernel.org,
	"Ivo van Doorn" <ivdoorn@gmail.com>,
	"John Linville" <linville@tuxdriver.com>,
	"Michael Buesch" <mb@bu3sch.de>, "Hong Liu" <hong.liu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:5034 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1753385AbWKCTOm
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Nov 2006 14:14:42 -0500
In-Reply-To: <200611031404.32926.flamingice@sourmilk.net>
To: "Michael Wu" <flamingice@sourmilk.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Wu wrote:

> So uh, what am I going to prefix all my printk messages with now that I
> can't
> access dev->name? It seems like the other d80211 drivers have a habit of
> prefixing their messages with the driver name (wrong thing to do, IMHO),
> which is different from pretty much all other network drivers.

Yeah, I thought about that and added that function to get the wiphy index.
cfg80211 makes the wiphy index an actual identifier that you can use to
enumerate all devices it has attached etc, so that makes sense. and d80211
also puts it into sysfs.

Is that good enough?

johannes
