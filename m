From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: reproducible kernel freeze using r8169 in Linux 3.0
Date: Tue, 3 Jan 2012 23:33:54 +0100
Message-ID: <20120103223354.GC8563@electric-eye.fr.zoreil.com>
References: <63CE35CA-7DD6-41EC-A745-6BA776D8C5E3@ginzton.net> <20111218083212.GA28286@electric-eye.fr.zoreil.com> <DED183BB-B51D-4739-99B3-7E0B71897159@ginzton.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nic_swsd@realtek.com, netdev@vger.kernel.org
To: Matt Ginzton <matt@ginzton.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:32937 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932206Ab2ACWm7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 17:42:59 -0500
Content-Disposition: inline
In-Reply-To: <DED183BB-B51D-4739-99B3-7E0B71897159@ginzton.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matt Ginzton <matt@ginzton.net> :
[...]
> Just to follow up on this old thread:

Thanks.

[...]
> I do note that TX performance as measured by pktgen is lower than r8168 --
> with r8169 in 3.2-rc7 I see something like 455MB/sec and with r8168, IIRC,
> the number was closer to 800MB/sec. This may be a very artificial statistic,
> and isn't something I happen to care about and I'm certainly not going to
> use r8168 because of it, but it may be worth looking into?

Expect a "remove everything from irq context" patch this week. It should
turn things simpler in the (apparently not so-) fast paths.

-- 
Ueimor
