From: ANDY KENNEDY <ANDY.KENNEDY@adtran.com>
Subject: RE: mdiobus_register() issue for an SMSC8720a PHY
Date: Wed, 6 Apr 2011 16:03:55 -0500
Message-ID: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA8DCDA@EXV1.corp.adtran.com>
References: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA0C0C6@EXV1.corp.adtran.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from p02c12o144.mxlogic.net ([208.65.145.77]:57509 "EHLO
	p02c12o144.mxlogic.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751297Ab1DFVD5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 17:03:57 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <9AC3F0E75060224C8BBC5BA2DDC8853A1FA0C0C6@EXV1.corp.adtran.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> ======  get_device_parent:689
> dev = 0x8781da40
> dev->class = 0x803c2ad4
> dev->class->p = 0x00000000
> dev->class->p->class_dirs = 0x00000048

Ughh.  I deleted a line of text from the e-mail I sent.  I found my
problem.  The line of text that would have given all of you the answer
quickly was this:

The below code is from arch/mips/<myboard>/platform.c.

Perhaps this is vague, so I'll clarify.  I start this process from the
board level configuration, therefore the mdio class (which gets created
in the init of mdiobus) isn't -- thus class->p is empty.


So, now I just need to relocate this code to some "real" network driver,
I guess.


Andy
