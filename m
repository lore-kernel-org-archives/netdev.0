From: "Matt Carlson" <mcarlson@broadcom.com>
Subject: dev_flags definitions in broadcom.c
Date: Wed, 28 Oct 2009 14:25:45 -0700
Message-ID: <20091028212545.GA9055@xw6200.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "Maciej W. Rozycki" <macro@linux-mips.org>,
	"Jeff Garzik" <jgarzik@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Nate Case" <ncase@xes-inc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:1897 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755909AbZJ1VZx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 17:25:53 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Nate, On May 17, 2008 you submitted a patch titled
"PHYLIB: Add 1000Base-X support for Broadcom bcm5482".  In that patch
you defined several dev_flags definitions for the broadcom module.  I
only see the PHY_BCM_FLAGS_MODE_1000BX being used in the code though.  I
quickly scanned through the phy_connect calls in drivers/net and didn't
see any caller using this preprocessor definition or an equivalent
hardcoded constant.  Perhaps I missed something though.  Can you tell me
where these flags are set?

My interest in this is several-fold.  First, I'd like to move the
definitions to include/linux/brcmphy.h so that the same preprocessor
definitons can be used at both ends.  But more important than that, I'd
like to get a handle on how many of these definitions are actually used
and how many are just placeholders.  With only 32-bits to use, the flags
might become a precious resource.  I have plans for a few of these bits
myself, and I'd like reviewers to take note of how they are used.

