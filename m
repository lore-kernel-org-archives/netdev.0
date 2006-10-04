From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Wed, 4 Oct 2006 18:38:04 +0200
Message-ID: <20061004183804.748706d6@griffin.suse.cz>
References: <4523DA7D.2080604@web.de>
	<200610041807.05266.IvDoorn@gmail.com>
	<4523E1D5.1060505@web.de>
	<200610041834.57918.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jan Kiszka <jan.kiszka@web.de>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:26803 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1161150AbWJDQiG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2006 12:38:06 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200610041834.57918.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Oct 2006 18:34:57 +0200, Ivo van Doorn wrote:
> You could replace the timer with a workqueue, the original patch
> also did that, so I think it would be good enough this time as well. :)

Yes, the timing isn't required to be precise here.

 Jiri

-- 
Jiri Benc
SUSE Labs
