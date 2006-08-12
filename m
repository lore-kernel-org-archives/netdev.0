From: Chris Wedgwood <cw@f00f.org>
Subject: Re: pci=routeirq solves EHCI-problem
Date: Sat, 12 Aug 2006 10:28:08 -0700
Message-ID: <20060812172808.GA14668@tuatara.stupidest.org>
References: <44D83CB6.7030406@lurban.de> <44D89F5D.2000106@lurban.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp111.sbc.mail.mud.yahoo.com ([68.142.198.210]:53946 "HELO
	smtp111.sbc.mail.mud.yahoo.com") by vger.kernel.org with SMTP
	id S932142AbWHLR2L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Aug 2006 13:28:11 -0400
To: Lutz Urban <lurban@lurban.de>
Content-Disposition: inline
In-Reply-To: <44D89F5D.2000106@lurban.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 08, 2006 at 04:27:41PM +0200, Lutz Urban wrote:

> I'm sorry to tell you that my previous message was bogus. The problem 
> still persists.

Daniel Drake has posted a fix that's in -mm you can try.  It's
probably the least painful solution to date, can you please try that:

    http://kernel.org/pub/linux/kernel/people/akpm/patches/2.6/2.6.18-rc2/2.6.18-rc2-mm1/broken-out/pci-quirk_via_irq-behaviour-change.patch

and let us know how it works for you.

I'd like to see this or something similar merged into mainline and
-stable pretty soon (pending problem reports from people).
