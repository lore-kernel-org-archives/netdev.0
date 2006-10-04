From: Jan Kiszka <jan.kiszka@web.de>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Wed, 04 Oct 2006 18:51:40 +0200
Message-ID: <4523E69C.1090408@web.de>
References: <4523DA7D.2080604@web.de>	<200610041807.05266.IvDoorn@gmail.com>	<4523E1D5.1060505@web.de>	<200610041834.57918.IvDoorn@gmail.com> <20061004183804.748706d6@griffin.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <ivdoorn@gmail.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate01.web.de ([217.72.192.221]:6860 "EHLO
	fmmailgate01.web.de") by vger.kernel.org with ESMTP
	id S1161602AbWJDQvv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 4 Oct 2006 12:51:51 -0400
To: Jiri Benc <jbenc@suse.cz>
In-Reply-To: <20061004183804.748706d6@griffin.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Benc wrote:
> On Wed, 4 Oct 2006 18:34:57 +0200, Ivo van Doorn wrote:
>> You could replace the timer with a workqueue, the original patch
>> also did that, so I think it would be good enough this time as well. :)
> 
> Yes, the timing isn't required to be precise here.

Ok, I'm not promising success and I'm going to duck immediately if
someone else feels like working on it, but I could try to patch in this
direction.

Now there just remains my precautious question if there are other
services in the ieee_80211_hw interface that may conflict with sleeping
USB drivers. What about specifying the possible contexts in
include/net/d80211.h?

Jan
