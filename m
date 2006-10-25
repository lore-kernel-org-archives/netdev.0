From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: tg3 driver fails with on-board BCM95789 NICS (GigaByte
 GA-7VCSV)
Date: Tue, 24 Oct 2006 21:31:56 -0700
Message-ID: <1551EAE59135BE47B544934E30FC4FC093FC6D@NT-IRVA-0751.brcm.ad.broadcom.com>
References: <7744a2840610241432i42364aaap672f8eb5bf25c066@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
 charset=us-ascii
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:57614 "EHLO
	mms2.broadcom.com") by vger.kernel.org with ESMTP id S1422867AbWJYEcK convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 00:32:10 -0400
Content-class: urn:content-classes:message
In-Reply-To: <7744a2840610241432i42364aaap672f8eb5bf25c066@mail.gmail.com>
To: "Richard Bollinger" <rabollinger@gmail.com>, netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Richard Bollinger wrote:

> GigaByte GA-7VCSV-RH motherboard w/two dual core Xeon's, 4gb RAM,
> Intel 5000v Chipset, dual Broadcom 5789 Gigabit Ethernet Controllers,
> connected to Dell GigE switch.
> 
> Both interfaces work fine with vendor's drivers on Windows 2003, but
> using Linux 2.6.18.1 tg3 or vendor's Linux driver, the first interface
> only works for a few packets, then stops receiving, while the second
> interface doesn't work at all - even to the point of recognizing the
> link is up or down.  Same results with 2.6.17.14 and non-smp kernel.
> 

Can you cat /proc/interrupts a few times to see if the interrupt
counts on eth1 and eth2 are increasing?

You can also run ethtool -t [eth1 | eth2] to run a basic selftest
on the 2 devices.  Be sure to ifconfig up first before the selftest.

Thanks.

