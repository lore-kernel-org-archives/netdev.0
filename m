From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: 2.6.29-rc3: tg3 dead after resume
Date: Fri, 30 Jan 2009 15:33:13 -0800 (PST)
Message-ID: <alpine.LFD.2.00.0901301532330.3150@localhost.localdomain>
References: <alpine.DEB.2.00.0901281858380.5048@parag-desktop> <alpine.LFD.2.00.0901281636270.3123@localhost.localdomain> <alpine.DEB.2.00.0901282049040.5026@parag-desktop> <20090129184215.GA13459@xw6200.broadcom.net> <alpine.DEB.2.00.0901291700130.5149@parag-desktop>
 <20090129222247.GA13861@xw6200.broadcom.net> <alpine.DEB.2.00.0901291730030.5149@parag-desktop> <20090130184030.GA14933@xw6200.broadcom.net> <alpine.DEB.2.00.0901301743410.4989@parag-desktop> <alpine.LFD.2.00.0901301506120.3150@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Andrew Morton <akpm@linux-foundation.org>
To: Parag Warudkar <parag.lkml@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41170 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753457AbZA3XdR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 18:33:17 -0500
In-Reply-To: <alpine.LFD.2.00.0901301506120.3150@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, 30 Jan 2009, Linus Torvalds wrote:
> 
> So just do that "lspci -vvxxx" for the whole box, before and after, and 
> send us the "before" and the "diff -u before after" thing, and maybe that 
> shows something interesting. Because some bridge chip being confused would 
> also explain why a total re-init of the whole tg3 chip by a driver unload 
> and reload doesn't seem to help.

It might also be instructive to see the same thing for a working kernel. I 
assume plain 2.6.28 works for you?

			Linus
