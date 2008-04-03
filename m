From: Meelis Roos <mroos@linux.ee>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip
 driver
Date: Thu, 3 Apr 2008 12:10:33 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0804031209540.2017@math.ut.ee>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: cebbert@redhat.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:59403 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755633AbYDCJKf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Apr 2008 05:10:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


CE> We have two reports that agree the tulip driver doesn't work for
CE> the Davicom 9102 (PCI id 1282:9102). The dmfe driver does work
CE> and also claims the same PCI ID.

NAK, dmfe does not work on some Sparc64 machines but tulip does.

I happent to have a Sun Fire V100 with 2 Davicom NICs (1282:9102 (rev 
31)).
tulip driver works for them, dmfe doesn't. Tried with 2.6.25-rc7, first 
it
gets MAC addresses all zeroed and second, it only results in Tx 
timeouts.

This issue was debugged somemonths ago on sparclinux mailing list. DaveM
fixed some bugs IIRC but it still does not work.

Sun Netra X1 is a similar Sun system with dmfe's.

-- 
Meelis Roos (mroos@linux.ee)
