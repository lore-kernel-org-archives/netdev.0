From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/2] d80211: Add software RTS support
Date: Mon, 5 Feb 2007 18:28:08 +0100
Message-ID: <20070205182808.2209ad3f@griffin.suse.cz>
References: <200701312016.50524.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>,
	Johannes Berg <johannes@sipsolutions.net>
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:41489 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752054AbXBER2M (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 12:28:12 -0500
In-Reply-To: <200701312016.50524.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 31 Jan 2007 20:16:50 +0100, Ivo van Doorn wrote:
> Not all hardware are capable of generating their own RTS frames.
> This patch will add support for creating the RTS frame in software,
> when the driver requests this through the flag
> IEEE80211_HW_SOFTWARE_RTS

It seems this is not the ideal solution. Most of drivers needing
software RTS would need to remember the RTS frame somewhere (as they
need to pass it together with the actual frame).

A better solution would be either to pass a pointer to RTS frame data
in tx_control or to create a function returning RTS frame.

 Jiri

-- 
Jiri Benc
SUSE Labs
