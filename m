From: David Miller <davem@davemloft.net>
Subject: Re: tg3 driver fails with on-board BCM95789 NICS (GigaByte
 GA-7VCSV)
Date: Tue, 24 Oct 2006 21:33:50 -0700 (PDT)
Message-ID: <20061024.213350.74746920.davem@davemloft.net>
References: <7744a2840610241432i42364aaap672f8eb5bf25c066@mail.gmail.com>
	<1551EAE59135BE47B544934E30FC4FC093FC6D@NT-IRVA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rabollinger@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:183
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1422951AbWJYEeg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 00:34:36 -0400
To: mchan@broadcom.com
In-Reply-To: <1551EAE59135BE47B544934E30FC4FC093FC6D@NT-IRVA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Michael Chan" <mchan@broadcom.com>
Date: Tue, 24 Oct 2006 21:31:56 -0700

> Can you cat /proc/interrupts a few times to see if the interrupt
> counts on eth1 and eth2 are increasing?
> 
> You can also run ethtool -t [eth1 | eth2] to run a basic selftest
> on the 2 devices.  Be sure to ifconfig up first before the selftest.

It's an interrupt routing problem for sure, Adrian Bunk
posted a potential fix to this poster an hour or so
ago.
