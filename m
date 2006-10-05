From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Thu, 5 Oct 2006 13:29:17 +0200
Message-ID: <20061005132917.78c985c1@griffin.suse.cz>
References: <4523DA7D.2080604@web.de>
	<200610041807.05266.IvDoorn@gmail.com>
	<4523E1D5.1060505@web.de>
	<200610041834.57918.IvDoorn@gmail.com>
	<20061004183804.748706d6@griffin.suse.cz>
	<4523E69C.1090408@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <ivdoorn@gmail.com>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:49796 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1750792AbWJEL3U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 07:29:20 -0400
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <4523E69C.1090408@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 04 Oct 2006 18:51:40 +0200, Jan Kiszka wrote:
> Ok, I'm not promising success and I'm going to duck immediately if
> someone else feels like working on it, but I could try to patch in this
> direction.

Your patches are welcomed!

> Now there just remains my precautious question if there are other
> services in the ieee_80211_hw interface that may conflict with sleeping
> USB drivers. What about specifying the possible contexts in
> include/net/d80211.h?

Yes, that makes sense. Feel free to send a patch :-)

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
