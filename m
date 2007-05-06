From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Merging SSB upstream
Date: Sun, 6 May 2007 11:41:18 +0200
Message-ID: <200705061141.18560.mb@bu3sch.de>
References: <200705060303.17594.mb@bu3sch.de> <463D4770.9060903@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: John Linville <linville@tuxdriver.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Gary Zambrano <zambrano@broadcom.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	bcm43xx-dev@lists.berlios.de
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:35912
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933482AbXEFJmQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 6 May 2007 05:42:16 -0400
In-Reply-To: <463D4770.9060903@garzik.org>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 06 May 2007 05:11:44 Jeff Garzik wrote:
> Michael Buesch wrote:
> > So, now that mac80211 is merged upstream, I think it's
> > time to merge SSB and the b44-ssb port upstream.
> > Note that bcm43xx-mac80211 is _not_ ready for upstream, yet.
> > 
> > What do you think? I'd like to merge ssb as-is, although
> > the embedded-device parts are not quite finished, yet.
> > But they don't interfere with the non-embedded parts used
> > by b44 and the bcm43xx PCI cards.
> > So we _could_ remove the ssb-mips code, but I don't like to
> > do that for better maintainability. It doesn't hurt anyone IMO.
> 
> What does Ralf (MIPS maintainer) and Gary (Broadcom maintainer) think?

I don't know. I wanted to get all these opinions with this mail. :)

> For my part, I'm not going to render even a tentative opinion without a 
> link to actual code.

All code is in wireless tree drivers/ssb
http://bu3sch.de/gitweb?p=wireless-dev.git;a=tree;f=drivers/ssb;h=681cd93bf166670efbdec471b78137d3d0f26537;hb=HEAD

-- 
Greetings Michael.
