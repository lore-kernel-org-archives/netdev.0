From: Dave Jones <davej@redhat.com>
Subject: Re: [PATCH] mark sk98lin driver for removal
Date: Sat, 22 Jul 2006 19:17:03 -0400
Message-ID: <20060722231703.GB8042@redhat.com>
References: <20060722141150.5994fee1@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:37507 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1751079AbWGVXRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Jul 2006 19:17:49 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060722141150.5994fee1@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Jul 22, 2006 at 02:11:50PM -0700, Stephen Hemminger wrote:
 > The sk98lin driver is now superseded by the skge driver. I wanted to just
 > let the old driver wither and die from old age, but there are still bugs
 > that are too painful to fix.
 > 
 > See http://bugzilla.kernel.org/show_bug.cgi?id=6780
 > The board crashes repeatedly after 2 weeks. It probably is something
 > in the vendor MIB code. That code is a mess, and starting over was one
 > of the motivations for creating the skge driver.
 > 
 > So rather than add more bondo to the old beater to cover the rusty bits,
 > throw it in the dustbin.
 > 
 > Signed-off-by: Stephen Hemminger <shemminger@osdl.or

After a huge number of bug reports in Fedora 'went away' when we
switched our users to using skge instead, I wholeheartedly endorse this.
sk98lin is a disaster.  The last time I looked the vendor out-of-tree
driver had a huge delta vs mainline, and backed out numerous fixes
made to it in the mainline kernel. It's a huge effort to get the 'good bits'
out of that patch, and letting it die is the only sensible solution IMO.

ACKed-by: Dave Jones <davej@redhat.com>


 > +SK98LIN GIGABBIT ETHERNET DRIVER

typo :-)

		Dave

-- 
http://www.codemonkey.org.uk
