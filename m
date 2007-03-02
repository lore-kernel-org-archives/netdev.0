From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: [git patches] net driver fixes
Date: Thu, 01 Mar 2007 23:41:10 -0800
Message-ID: <45E7D516.30401@intel.com>
References: <20070227110233.GA14138@havoc.gtf.org> <Pine.LNX.4.64.0703012001110.7832@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:36329 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932702AbXCBHlS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Mar 2007 02:41:18 -0500
In-Reply-To: <Pine.LNX.4.64.0703012001110.7832@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linus Torvalds wrote:
> 
> Ok, here's an interesting one: my e1000 card no longer worked for a while.
> 
> The green link-light blinks on/off once a second, and in time to that, my 
> dmesg fills up with an endless supply of
> 
> 	e1000: eth0: e1000_watchdog: NIC Link is Down
> 	e1000: eth0: e1000_watchdog: NIC Link is Up 100 Mbps Full Duplex, Flow Control: None
> 	e1000: eth0: e1000_watchdog: 10/100 speed: disabling TSO
> 
> and networking obviously doesn't actually work.

Just out of curiosity, which e1000 chipset+motherboard are you running this on? 
there have been problems reported with AMT2 on several chipsets (AMT2 is not 
supported under linux, unlike AMT1), and having it enabled in the BIOS produces 
this phenomenon.

I have to dig up which nic was affected, don't know by heart.

Cheers,

Auke
