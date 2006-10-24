From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [patch 1/2]d80211: hardware TKIP support for ipw3945
Date: Tue, 24 Oct 2006 11:12:39 +0200
Message-ID: <1161681159.2840.25.camel@ux156>
References: <1161335976.21402.11.camel@devlinux-hong>
	 <20061023144028.629dc5d8@griffin.suse.cz> <1161607680.6617.36.camel@ux156>
	 <20061023145646.32bbd59f@griffin.suse.cz>
	 <1161678053.7083.7.camel@devlinux-hong>  <1161678908.2840.12.camel@ux156>
	 <1161679134.7258.6.camel@devlinux-hong>  <1161681021.2840.23.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jiri Benc <jbenc@suse.cz>,
	"John W. Linville" <linville@tuxdriver.com>,
	netdev <netdev@vger.kernel.org>, Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:56030 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S1030217AbWJXJLj
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Oct 2006 05:11:39 -0400
To: Hong Liu <hong.liu@intel.com>
In-Reply-To: <1161681021.2840.23.camel@ux156>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-24 at 11:10 +0200, Johannes Berg wrote:

> How about having the stack maintain
> the IV *only*, 

The idea here is that even if not required by hw that does both, it's
cheap to maintain this counter. Though for all I care the driver could
do it too.

johannes
