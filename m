From: Meelis Roos <mroos@linux.ee>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip
 driver
Date: Fri, 4 Apr 2008 11:56:44 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0804041154150.11646@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:36372 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753597AbYDDI4p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Apr 2008 04:56:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>> -     { 0x1282, 0x9102, PCI_ANY_ID, PCI_ANY_ID, 0, 0, DM910X },

> applied

Hmm, did you see my yesterdays answer to that patch - that dmfe should 
first be fixed to work on all  cards with this PCI ID? Currenty dmfe 
fails to work on at least Sun Fire V100 and Sun Netra X1 boxes, only 
tulip works.

-- 
Meelis Roos (mroos@linux.ee)
