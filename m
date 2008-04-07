From: Meelis Roos <mroos@linux.ee>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip
 driver
Date: Mon, 7 Apr 2008 17:28:03 +0300 (EEST)
Message-ID: <Pine.SOC.4.64.0804071726210.29033@math.ut.ee>
References: <Pine.SOC.4.64.0804031209540.2017@math.ut.ee> <47F69FBE.3020308@garzik.org>
 <20080404232650.GE27826@colo.lackof.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Jeff Garzik <jeff@garzik.org>, cebbert@redhat.com,
	netdev@vger.kernel.org
To: Grant Grundler <grundler@parisc-linux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.it.da.ut.ee ([193.40.5.67]:34115 "EHLO smtp2.it.da.ut.ee"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753575AbYDGO2G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Apr 2008 10:28:06 -0400
In-Reply-To: <20080404232650.GE27826@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> jeff and davem already answered the basic SROM/MAC address issue.
> Patches to fix this are associated with
> 	http://bugzilla.kernel.org/show_bug.cgi?id=9106

> >> I happent to have a Sun Fire V100 with 2 Davicom NICs (1282:9102 (rev 
> >> 31)).
> >> tulip driver works for them, dmfe doesn't.
> 
> This experience doesn't agree with the bug report.
> Meelis, can you please take a look at the bug report and add comments?

Comments added.

> We tried (b) but didn't get it working on V100 previously.
> Several patches are attached to the bug report.

There was one patch (for getting the MAC from OpenFirmware) but as 
people reported that the Tx timeouts still happen, I didn't try it. Any 
reason to try?

-- 
Meelis Roos (mroos@linux.ee)
