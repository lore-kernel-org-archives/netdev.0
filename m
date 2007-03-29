From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [2.6 patch] the scheduled eepro100 removal
Date: Thu, 29 Mar 2007 09:22:50 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5202357DB0@orsmsx418.amr.corp.intel.com>
References: <460B76A3.6040200@drugphish.ch>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Jeff Garzik" <jgarzik@pobox.com>,
	"Kok, Auke-jan H" <auke-jan.h.kok@intel.com>,
	"Bill Davidsen" <davidsen@tmr.com>, "Adrian Bunk" <bunk@stusta.de>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<saw@saw.sw.com.sg>
To: "Roberto Nibali" <ratz@drugphish.ch>,
	"Yinghai Lu" <yinghai.lu@amd.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:23227 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933143AbXC2QXE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Mar 2007 12:23:04 -0400
Content-class: urn:content-classes:message
In-Reply-To: <460B76A3.6040200@drugphish.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roberto Nibali wrote:
>>> Sounds sane to me.  My overall opinion on eepro100 removal is that
>>> we're not there yet.  Rare problem cases remain where e100 fails
>>> but eepro100 works, and it's older drivers so its low priority for
>>> everybody. 
>>> 
>>> Needs to happen, though...
>> 
>> It seems that several Tyan Opteron base system that were using IPMI
>> add on card.  the IPMI card share intel 100Mhz nic onboard. you need
>> to use eepro100 instead of e100 otherwise the e100 will shutdown OOB
>> (out of Band) connection for IPMI when shut down the OS.
> 
> I find it hard to believe that something as common as IPMI in
> conjunction with the IPMI technology wasn't tested in Intel's lab.
> From my experience with Intel Server boards, onboard IPMI (all offered
> versions) and e100/e1000 NICs, I've never ever experienced any
> problems operating the BMC over the NIC. Also, I don't quite
> understand you point about the "IPMI card sharing the 100Mbit/s NIC"
> onboard? What exactly is shared?

It's a legit problem, but only with this *one* system.
