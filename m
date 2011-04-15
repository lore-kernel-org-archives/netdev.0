From: Martin Topholm <mph@hoth.dk>
Subject: Re: Feature request: "inverted" ping -a (beep on failure)
Date: Fri, 15 Apr 2011 23:57:01 +0200
Message-ID: <20110415215700.GA9300@hoth.dk>
References: <201104152135.33171@tux.boltz.de.vu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Christian Boltz <netdev-vger-kernel.org@cboltz.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from solo.hoth.dk ([88.198.14.10]:29568 "EHLO solo.hoth.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757216Ab1DOWFP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 15 Apr 2011 18:05:15 -0400
Content-Disposition: inline
In-Reply-To: <201104152135.33171@tux.boltz.de.vu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 15 Apr 2011, Christian Boltz wrote:
> I'd like to have the exact opposite of it: beep when pinging fails.

I too have missed this feature (from the BSDs ping). Also I needed
adhoc tracking of multiple hosts. So I experimented with libevent2 and
some code from the BSD ping...

You can see the result here http://hoth.dk/xping/screenshot.jpeg
or http://hoth.dk/xping/xping-20110415.tar.gz .

> I understand that this is slightly difficult because "ping success" is 
> easier to detect (incoming package) than "ping failure" (no incoming 
> package or firewall reject)

I used the transmit interval for timeout. There's propably a lot of
corner cases I haven't thought about, but it works fairly well.

Regards, Martin
