From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 10790] New: driver "sunhme" experiences corrupt packets
 if machine has more than 2GB of memory (fwd)
Date: Tue, 03 Jun 2008 16:27:32 -0700 (PDT)
Message-ID: <20080603.162732.208550164.davem@davemloft.net>
References: <20080525173008.GE1791@cs181133002.pp.htv.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	jeff@garzik.org
To: bunk@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46628
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753190AbYFCX1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jun 2008 19:27:33 -0400
In-Reply-To: <20080525173008.GE1791@cs181133002.pp.htv.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Adrian Bunk <bunk@kernel.org>
Date: Sun, 25 May 2008 20:30:08 +0300

> David, can you look at this bug (email answers to this email are fine)?

I've been looking on and off at this bug and haven't forgotten it.

I've checked the obvious things like whether the PCI front-end supports
full 32-bit addresses (all documentation states that it does) or whether
there is some signedness issue with how the driver handles DMA
addresses (I cannot find any such problems).

I'll reply again if I make any more progress on this bug.

I do have a QFE card somewhere and an x86 system with 4GB of ram
so I might try to reproduce this problem locally in the end.
