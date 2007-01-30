From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] block MSI on Sony
Date: Mon, 29 Jan 2007 16:31:43 -0800
Message-ID: <20070129163143.30e9e930@freekitty>
References: <Pine.LNX.4.64.0701241847360.25027@woody.linux-foundation.org>
	<1169931333.17469.125.camel@localhost.localdomain>
	<20070129113159.7ad22e4c@freekitty>
	<1170101430.29240.34.camel@localhost.localdomain>
	<20070129133849.1b523226@freekitty>
	<1170109401.29240.49.camel@localhost.localdomain>
	<1170110318.21603.25.camel@funkylaptop>
	<1170110732.29240.59.camel@localhost.localdomain>
	<1170111056.21603.30.camel@funkylaptop>
	<1170111464.29240.63.camel@localhost.localdomain>
	<1170113200.21603.41.camel@funkylaptop>
	<1170113879.29240.79.camel@localhost.localdomain>
	<20070129155043.56a1c577@freekitty>
	<1170116575.29240.114.camel@localhost.localdomain>
	<20070129162153.6b3b5eff@freekitty>
	<1170117094.29240.121.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: =?UTF-8?B?RnLDqWTDqXJpYw==?= Riss <frederic.riss@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:35210 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965041AbXA3AeR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 19:34:17 -0500
In-Reply-To: <1170117094.29240.121.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 30 Jan 2007 01:31:33 +0100
Thomas Gleixner <tglx@linutronix.de> wrote:

> On Mon, 2007-01-29 at 16:21 -0800, Stephen Hemminger wrote:
> > > > The Sony VAIO BIOS resets to INTx on resume. This happens
> > > > after device resume, so device irq's get misrouted.
> > > 
> > > Err? My Sony VAIO does _NOT_ do that. It works fine without that. 
> > > It's just the sky2 hackery which fucked up things.
> > 
> > What machine and BIOS version?
> 
> VGN-SZ2XP_C
> BIOS: R0081N0

Mine is:
	VGN-N170G
	BIOS: R0020J4

It might be BIOS bug that has been fixed, but updating the
BIOS requires Windows. It checks for some ID so even Wine
won't work.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
