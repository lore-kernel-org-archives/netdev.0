From: Parag Warudkar <parag.lkml@gmail.com>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 17:31:42 -0500 (EST)
Message-ID: <alpine.DEB.2.00.0901301730230.6574@parag-desktop>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <200901300003.38550.rjw@sisk.pl> <20090129234127.GA14023@xw6200.broadcom.net> <200901300110.56533.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Carlson <mcarlson@broadcom.com>,
	Parag Warudkar <parag.lkml@gmail.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.28]:29614 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754522AbZA3Wbx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 17:31:53 -0500
In-Reply-To: <200901300110.56533.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Jan 2009, Rafael J. Wysocki wrote:

> 
> I still am interested if it makes any difference for Parag.

No difference - tg3 is still dead after resume.

BTW, I applied the patch on top of the one Matt gave earlier.
Machine booted with original tg3 which I rmmod'ed and then insmod'ed the 
new one (with Matt's and Rafael's patch) and then attempted a 
suspend-resume.

Is there a reason to try fresh boot with patched tg3 and without 
loading old module - I guess I will try that one later as well.

Thanks
Parag
