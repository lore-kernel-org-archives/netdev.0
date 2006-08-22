From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH 11/18] d80211:  clean up qdisc requeue
Date: Tue, 22 Aug 2006 09:48:15 +0200
Message-ID: <1156232895.3621.6.camel@ux156>
References: <20060821074107.648561364@sipsolutions.net>
	 <20060821075200.982958463@sipsolutions.net>
	 <20060821213104.56cdd40f@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jouni Malinen <jkm@devicescape.com>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42944 "EHLO
	sipsolutions.net") by vger.kernel.org with ESMTP id S932065AbWHVHs2
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Aug 2006 03:48:28 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20060821213104.56cdd40f@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2006-08-21 at 21:31 +0200, Jiri Benc wrote:
> to 802.11 qdisc dequeue function and then 0 will be a valid return code
> from ieee80211_tx.

Surely you mean non-zero here? :)

How will that work in the case where NET_SCHED is enabled?

johannes
