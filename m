From: Richard Gregory <R.Gregory@liverpool.ac.uk>
Subject: Re: r8169+NAPI soft lockup
Date: Sat, 03 Jun 2006 16:05:37 +0100
Message-ID: <4481A541.4080108@liv.ac.uk>
References: <4460B8DC.9080105@liv.ac.uk> <20060510215004.GA25395@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.liv.ac.uk ([138.253.100.180]:8348 "EHLO mx2.liv.ac.uk")
	by vger.kernel.org with ESMTP id S1750962AbWFCPFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 3 Jun 2006 11:05:41 -0400
Received: from mailhuba.liv.ac.uk ([138.253.100.36])
	by mx2.liv.ac.uk with esmtp (Exim 4.54)
	id 1FmXh6-0001jB-7u
	for netdev@vger.kernel.org; Sat, 03 Jun 2006 16:05:40 +0100
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
In-Reply-To: <20060510215004.GA25395@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

A little more info to the dead thread...

The machine died this morning, network and serial console were 
unresponsive. On rebooting, the only unusual message in logs were the 
last two:
Jun  3 01:58:39 loft -- MARK --
Jun  3 02:03:39 loft -- MARK --
Jun  3 02:08:40 loft -- MARK --
Jun  3 02:10:26 loft smartd[18830]: Device: /dev/hda, starting scheduled 
Short Self-Test.
Jun  3 02:10:27 loft smartd[18830]: Device: /dev/hdc, starting scheduled 
Short Self-Test.
Jun  3 02:10:27 loft smartd[18830]: Device: /dev/hde, starting scheduled 
Short Self-Test.
Jun  3 02:10:28 loft smartd[18830]: Device: /dev/hdg, starting scheduled 
Short Self-Test.
Jun  3 02:10:28 loft smartd[18830]: Device: /dev/hdi, starting scheduled 
Short Self-Test.
Jun  3 02:10:29 loft smartd[18830]: Device: /dev/hdk, starting scheduled 
Short Self-Test.
Jun  3 02:10:30 loft smartd[18830]: Device: /dev/hdm, starting scheduled 
Short Self-Test.
Jun  3 02:10:31 loft smartd[18830]: Device: /dev/hdo, starting scheduled 
Short Self-Test.
Jun  3 02:10:32 loft smartd[18830]: Device: /dev/hdq, starting scheduled 
Short Self-Test.
Jun  3 02:10:32 loft smartd[18830]: Device: /dev/hds, starting scheduled 
Short Self-Test.
Jun  3 02:13:26 loft kernel: hdo: lost interrupt
Jun  3 02:13:46 loft kernel: hdo: dma_timer_expiry: dma status == 0x21

'lost interrupt' has never been seen before in the logs.

I guess this more strongly implicates the it821x driver.


Richard
