From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] d80211: ieee80211_hw handlers should be allowed to
 sleep
Date: Thu, 19 Oct 2006 18:01:17 +0200
Message-ID: <20061019180117.4833ee4d@griffin.suse.cz>
References: <200610071123.15561.IvDoorn@gmail.com>
	<20061018150609.6542af30@griffin.suse.cz>
	<200610181927.37471.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jan Kiszka <jan.kiszka@web.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:13033 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1946145AbWJSQBU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2006 12:01:20 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200610181927.37471.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 18 Oct 2006 19:27:37 +0200, Ivo van Doorn wrote:
> Would something like the patch below be better?
> It keeps the flush_scheduled_work() at the same location, but a second
> is added in case local->scan_work.data != sdata->dev

Applied to my tree, thanks for the patch!

 Jiri

-- 
Jiri Benc
SUSE Labs
