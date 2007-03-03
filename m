From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC] div64_64 support
Date: 03 Mar 2007 03:31:52 +0100
Message-ID: <p73slcnawh3.fsf@bingen.suse.de>
References: <20070223170527.4ca695b2@freekitty>
	<Pine.LNX.4.61.0702262108010.23355@yvahk01.tjqt.qr>
	<20070226143127.5c74bec9@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jan Engelhardt <jengelh@linux01.gwdg.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:34916 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S2992880AbXCCBcP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 20:32:15 -0500
In-Reply-To: <20070226143127.5c74bec9@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@linux-foundation.org> writes:

> Here is another way to handle the 64 bit divide case.
> It allows full 64 bit divide by adding the support routine
> GCC needs.

Not supplying that was intentional by Linus so that people
think twice (or more often) before they using such expensive
operations. A plain / looks too innocent.

Is it really needed by CUBIC anyways?  It uses it for getting
the cubic root, but the algorithm recommended by Hacker's Delight
(great book) doesn't use any divisions at all. Probably better 
to use a better algorithm without divisions.

-Andi
