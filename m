From: Matthew Garrett <mjg59@srcf.ucam.org>
Subject: Re: [PATCH] bcm43xx: Fix code for spec changes of 2/7/2007
Date: Fri, 9 Feb 2007 21:32:39 +0000
Message-ID: <20070209213239.GA11650@srcf.ucam.org>
References: <45cca236.+lL/rsW3DbM3elnk%Larry.Finger@lwfinger.net> <200702091811.40683.mb@bu3sch.de> <45CCF432.2070002@gentoo.org> <200702091829.51002.mb@bu3sch.de> <45CCBB93.2040703@lwfinger.net> <45CCC5DF.8010001@gentoo.org> <45CCCAE1.9080901@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joseph Jezak <josejx@gentoo.org>, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org,
	John Linville <linville@tuxdriver.com>,
	Michael Buesch <mb@bu3sch.de>, Bcm43xx-dev@lists.berlios.de
To: Larry Finger <larry.finger@lwfinger.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cavan.codon.org.uk ([217.147.92.49]:49013 "EHLO
	vavatch.codon.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752519AbXBIVdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Feb 2007 16:33:06 -0500
Content-Disposition: inline
In-Reply-To: <45CCCAE1.9080901@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Feb 09, 2007 at 01:26:25PM -0600, Larry Finger wrote:

> My plan is to continue to maintain bcm43xx-SoftMAC for at least the BPHY and 4306 revisions even
> after d80211 becomes the in-kernel driver. Of course, I hope that we will have found the killer bugs
> by that time, and that maintenance will only require following kernel API changes.

Just to make sure I'm understanding this correctly - does the v4 
firmware drop compatibility for older cards, or is it just that Broadcom 
dropped support in the driver at the same time as the firmware changed, 
and the new firmware will still also drive the old cards?

-- 
Matthew Garrett | mjg59@srcf.ucam.org
