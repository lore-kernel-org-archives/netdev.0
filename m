From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 14:36:33 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901301436050.3150@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901300003.38550.rjw@sisk.pl> <20090129234127.GA14023@xw6200.broadcom.net> <200901300110.56533.rjw@sisk.pl> <alpine.DEB.2.00.0901301730230.6574@parag-desktop>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:56407 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752503AbZA3WhJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:37:09 -0500
In-Reply-To: <alpine.DEB.2.00.0901301730230.6574@parag-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Jan 2009, Parag Warudkar wrote:
> 
> BTW, I applied the patch on top of the one Matt gave earlier.
> Machine booted with original tg3 which I rmmod'ed and then insmod'ed the 
> new one (with Matt's and Rafael's patch) and then attempted a 
> suspend-resume.
> 
> Is there a reason to try fresh boot with patched tg3 and without 
> loading old module - I guess I will try that one later as well.

As long as you didn't suspend/resume with the old module loaded, it really 
shouldn't matter.

			Linus
