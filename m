From: Jiri Benc <jbenc@suse.cz>
Subject: Re: d80211: How does TX flow control work?
Date: Wed, 10 Jan 2007 19:20:12 +0100
Message-ID: <20070110192012.341b2612@griffin.suse.cz>
References: <459A5945.80909@web.de>
	<20070103185203.2754e059@griffin.suse.cz>
	<459BF179.6000906@web.de>
	<20070103191853.4f440b8b@griffin.suse.cz>
	<459BFB05.9040608@web.de>
	<45A03825.9080807@web.de>
	<45A2A728.1070404@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Ivo Van Doorn <ivdoorn@gmail.com>,
	rt2400-devel@lists.sourceforge.net,
	Jouni Malinen <jkm@devicescape.com>,
	Simon Barber <simon@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:33981 "EHLO mail.suse.cz"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S965014AbXAJSUP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Jan 2007 13:20:15 -0500
To: Jan Kiszka <jan.kiszka@web.de>
In-Reply-To: <45A2A728.1070404@web.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 08 Jan 2007 21:18:48 +0100, Jan Kiszka wrote:
> The actual problem was meanwhile identified: shorewall happened to
> overwrite the queueing discipline of wmaster0 with pfifo_fast. I found
> the magic knob to tell shorewall to no longer do this (at least until I
> want to manage traffic control that way...), but I still wonder if it is
> an acceptable situation. Currently, the user can intentionally or
> accidentally screw up the stack this way.

Hm, we probably need a way to tell the kernel not to remove 802.11
qdisc. Jouni, Simon, is that possible or do we need to patch NET_SCHED
code?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
