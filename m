From: Thomas Gleixner <tglx@linutronix.de>
Subject: Re: [PATCH] block MSI on Sony
Date: Tue, 30 Jan 2007 01:22:54 +0100
Message-ID: <1170116575.29240.114.camel@localhost.localdomain>
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
Reply-To: tglx@linutronix.de
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: =?ISO-8859-1?Q?Fr=E9d=E9ric?= Riss <frederic.riss@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.osadl.org ([213.239.205.134]:55377 "EHLO mail.tglx.de"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964851AbXA3AWO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 19:22:14 -0500
In-Reply-To: <20070129155043.56a1c577@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-01-29 at 15:50 -0800, Stephen Hemminger wrote:
> The Sony VAIO BIOS resets to INTx on resume. This happens
> after device resume, so device irq's get misrouted.

Err? My Sony VAIO does _NOT_ do that. It works fine without that. 
It's just the sky2 hackery which fucked up things.

	tglx


	

