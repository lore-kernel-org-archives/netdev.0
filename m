From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH 1/2] d80211: Add software RTS support
Date: Mon, 5 Feb 2007 19:08:34 +0100
Message-ID: <20070205190834.40c0a619@griffin.suse.cz>
References: <200701312016.50524.IvDoorn@gmail.com>
	<20070205182808.2209ad3f@griffin.suse.cz>
	<200702051843.07026.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ivo van Doorn <ivdoorn@gmail.com>,
	"John Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Michael Buesch <mbuesch@freenet.de>,
	Johannes Berg <johannes@sipsolutions.net>
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:42598 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752154AbXBESIg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 13:08:36 -0500
In-Reply-To: <200702051843.07026.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 5 Feb 2007 18:43:06 +0100, Michael Buesch wrote:
> I also think that sending RTS in software is not going to work,
> as the timing can not be guaranteed. And timing is why we do it in
> the first place. If the HW is not capable of sending RTS frames, we
> should not try to emulate them in SW, as it might make the situation
> even worse by messing up the NAVs by wrong timing.

That's not emulation in the software, it's just similar approach as
with sending fragmented frames - you need (more or less) precise timing
there as well and many cards still want them enqueued one-by-one. The
firmware takes care of the precise timing. The same could apply to RTS
frames (i. e. the firmware recognize them and doesn't send them before
it has the next frame ready).

 Jiri

-- 
Jiri Benc
SUSE Labs
