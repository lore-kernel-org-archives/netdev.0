From: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
Subject: Re: [PATCH -mm 1/2] 3c59x: Fix uninitialized variable bug
Date: Tue, 4 Sep 2007 10:16:02 +0200
Message-ID: <20070904081602.GB4241@newton.mathematik.tu-chemnitz.de>
References: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>,
	Mark Hindley <mark@hindley.org.uk>
To: Satyam Sharma <satyam@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from john.hrz.tu-chemnitz.de ([134.109.132.2]:59792 "EHLO
	john.hrz.tu-chemnitz.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751616AbXIDIQF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Sep 2007 04:16:05 -0400
Content-Disposition: inline
In-Reply-To: <alpine.LFD.0.999.0709040340250.8504@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Sep 04, 2007 at 03:45:55AM +0530, Satyam Sharma wrote:
> 
> drivers/net/3c59x.c: In function 'vortex_up':
> drivers/net/3c59x.c:1495: warning: 'err' may be used uninitialized in this function

This came in with the recently applied 3c59x-check-return-of-pci_enable_device patch
from Mark Hindley. I just compiled it on a PCI only machine so far, therefore I did
not notice the warning yet.

> 
> is a genuine bug. The function returns an uninitialized value of 'err'
> back to the caller, which expects it to be 0 for success cases. Let's
> fix this by explicitly initializing 'err' to zero.
> 
> Signed-off-by: Satyam Sharma <satyam@infradead.org>
Acked-by: Steffen Klassert <klassert@mathematik.tu-chemnitz.de>
