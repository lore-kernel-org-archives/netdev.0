From: Jeff Garzik <jeff@garzik.org>
Subject: Re: Sanitise ethtool.h and mii.h for userspace.
Date: Tue, 20 Jun 2006 21:18:27 -0400
Message-ID: <44989E63.9010300@garzik.org>
References: <200606202308.k5KN83bT013398@hera.kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Netdev List <netdev@vger.kernel.org>,
	Andrew Morton <akpm@osdl.org>,
	Linus Torvalds <torvalds@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:8835 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1750834AbWFUBSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 21:18:30 -0400
To: David Woodhouse <dwmw2@infradead.org>
In-Reply-To: <200606202308.k5KN83bT013398@hera.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linux Kernel Mailing List wrote:
> commit c3ce7e203af5d8eab7c3390fc991a1fcb152f741
> tree 43b0837c42a1deb5b0f87800bf6a5ed8eea2eafe
> parent 56142536868a2be34f261ed8fdca1610f8a73fbd
> author David Woodhouse <dwmw2@shinybook.infradead.org> Sat, 29 Apr 2006 01:53:47 +0100
> committer David Woodhouse <dwmw2@infradead.org> Sat, 29 Apr 2006 01:53:47 +0100
> 
> Sanitise ethtool.h and mii.h for userspace.
> 
> They shouldn't be using 'u32' et al in structures which are used for
> communication with userspace. Switch to the proper types (__u32 etc).
> 
> Signed-off-by: David Woodhouse <dwmw2@infradead.org>

How can reviewers make an informed decision, when you completely failed 
to note:

* This breaks the primary userspace user of this header, ethtool(8)
* The patch was NAK'd (and I don't even get a "Naked-by:" header :))
* Despite knowing all this for quite some time, no associated userspace 
fix patch has ever appeared.

If you are going to break stuff, AT LEAST TELL PEOPLE IN ALL CAPS ABOUT 
IT, rather than providing the highly deceptive description as above. 
And be courteous enough to help fix the breakage, if you please.

	Jeff, ethtool maintainer



