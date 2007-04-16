From: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Subject: RE: 2.6.21rc7 e1000 media-detect oddness.
Date: Mon, 16 Apr 2007 10:04:33 -0700
Message-ID: <08FE5CC30C9A3F41BF819A502CF7BF6E0117FC22@fmsmsx411.amr.corp.intel.com>
References: <20070416034539.GC21217@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "Dave Jones" <davej@redhat.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:4781 "EHLO mga03.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030891AbXDPREs convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 13:04:48 -0400
Content-class: urn:content-classes:message
In-Reply-To: <20070416034539.GC21217@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave Jones wrote:
> I booted up 2.6.21rc7 without an ethernet cable plugged in,
> and noticed this..
> 
> e1000: 0000:02:00.0: e1000_probe: The EEPROM Checksum Is Not Valid
> e1000: probe of 0000:02:00.0 failed with error -5
> 
> I plugged a cable in, did rmmod e1000;modprobe e1000, and got this..
> 
> e1000: 0000:02:00.0: e1000_probe: (PCI Express:2.5Gb/s:Width x1)
> 00:16:d3:3a:62:d3 e1000: eth0: e1000_probe: Intel(R) PRO/1000 Network
> Connection 
> e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex,
> Flow Control: RX e1000: eth0: e1000_watchdog: 10/100 speed: disabling
> TSO 
> 
> and it works fine..
> Why would no cable make it think the EEPROM is invalid ?

There was a similar issue reported a while back on T60 and it had to do
with power management:
http://forums.gentoo.org/viewtopic-t-476305-highlight-e1000.html

Some questions:
What was the system in your case (lspci -vv)? 

> 
> I repeated this a few times, just to be sure it wasn't a fluke, and it
> seems to happen 100% reproducably.

Can you reproduce this with the latest driver from e1000.sf.net?

Thanks,
Emil
