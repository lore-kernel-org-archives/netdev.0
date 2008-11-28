From: Jay Cliburn <jcliburn@gmail.com>
Subject: Re: oops/warning report for the week of November 26, 2008
Date: Fri, 28 Nov 2008 11:18:27 -0600
Message-ID: <20081128111827.79b12739@osprey.hogchain.net>
References: <492DD792.6080302@linux.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Arjan van de Ven <arjan@linux.intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.236]:19666 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528AbYK1RSd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Nov 2008 12:18:33 -0500
Received: by rv-out-0506.google.com with SMTP id k40so1443707rvb.1
        for <netdev@vger.kernel.org>; Fri, 28 Nov 2008 09:18:32 -0800 (PST)
In-Reply-To: <492DD792.6080302@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[trimmed the cc list down to netdev only]

On Wed, 26 Nov 2008 15:11:14 -0800
Arjan van de Ven <arjan@linux.intel.com> wrote:


> Rank 12: dev_watchdog(atl1) (oops)
> 	Reported 56 times (109 total reports)
> 	This oops was last seen in version 2.6.27.5, and first seen
> in 2.6.26.6. More info:
> http://www.kerneloops.org/searchweek.php?search=dev_watchdog(atl1)

I can't reproduce this, so I've launched a request at fedoraforum.org
hoping I can snag a Fedora user who's encountering the bug and willing
to test.

The tx timeout reports at kerneloops.org appear to be happening on a
startling variety of network drivers (startling to me, anyway): r8169,
atl1, atl2, sis900, cdc_ether, orinoco_cs, tg3, ne2k-pci, via-rhine,
8139too, ath_pci, e1000, gl620a, sky2, hso, fealnx, forcedeth; probably
others, but I quit looking.

Is it correct to assume all these drivers are showing symptoms of the
poor timeout handling you mentioned in your r8169 comment, or is the
occasional tx timeout to be expected, and the leaders in this category
(r8169, sis900, atl1) are the only ones suffering from deficient
timeout handling?

Jay
