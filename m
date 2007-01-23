From: Michael Buesch <mb@bu3sch.de>
Subject: Re: [PATCH] bcm43xx: Fix problem with >1 GB RAM
Date: Tue, 23 Jan 2007 16:22:23 +0100
Message-ID: <200701231622.24054.mb@bu3sch.de>
References: <45b240d6.SHryQ/4Jr/1MvQso%Larry.Finger@lwfinger.net> <45B51C31.10000@lwfinger.net> <1169565516.2777.13.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <larry.finger@lwfinger.net>,
	John Linville <linville@tuxdriver.com>, netdev@vger.kernel.org,
	Bcm43xx-dev@lists.berlios.de, Jiri Benc <jbenc@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:48518
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751990AbXAWPXw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jan 2007 10:23:52 -0500
To: Dan Williams <dcbw@redhat.com>
In-Reply-To: <1169565516.2777.13.camel@localhost.localdomain>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 23 January 2007 16:18, Dan Williams wrote:
> > At present, I have a problem getting NetworkManager to see the d80211 wireless interface. Once I get
> > that solved, I plan to use my system to test with > 1 GB RAM on your git tree. In that case, I'll
> > switch to the pci-form only if necessary.
> 
> NM should show the interface if HAL sees the interface and has assigned
> it a "net.80211" capability.  We had all agreed that HAL should be a bit
> smarter about detecting d80211 devices, but we were postponing that
> until we figured out what to do with the master device.  Now that we

Jiri already has a working patch for that.
I think he will commit it, soon.

-- 
Greetings Michael.
