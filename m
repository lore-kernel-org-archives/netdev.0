From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211: ieee80211_hw handlers in atomic context
Date: Thu, 5 Oct 2006 13:37:09 +0200
Message-ID: <20061005133709.36a764c0@griffin.suse.cz>
References: <4523DA7D.2080604@web.de>
	<20061004183804.748706d6@griffin.suse.cz>
	<4523E69C.1090408@web.de>
	<200610041922.39079.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jan Kiszka <jan.kiszka@web.de>, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:17285 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1751690AbWJELhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2006 07:37:12 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200610041922.39079.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 4 Oct 2006 19:22:38 +0200, Ivo van Doorn wrote:
> Well another point of concern for me is the TSF handling, those handlers are called
> from interrupt context as well, and also deliver problems for the USB drivers in case
> of adhoc mode.

Where is a problem with tsf handlers? get_tsf is not called at all
(unless CONFIG_D80211_IBSS_DEBUG is set; well, that raises a question
why the function exists in the first place), reset_tsf returns void.

 Jiri

-- 
Jiri Benc
SUSE Labs
