From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: Re: e1000 driver problems
Date: Mon, 03 Dec 2007 07:20:48 -0800
Message-ID: <47541ED0.9090808@intel.com>
References: <20061017205316.25914.qmail@web83109.mail.mud.yahoo.com> <45354850.6050900@intel.com> <20071120143803.GA5638@ics.muni.cz> <474B5610.4030800@intel.com> <20071127150700.GB4365@ics.muni.cz> <474C4A74.90705@intel.com> <20071127173146.GG4365@ics.muni.cz> <474C5678.3060609@intel.com> <20071127174456.GH4365@ics.muni.cz> <474C6084.9000301@intel.com> <20071203095023.GG26573@ics.muni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
To: Lukas Hejtmanek <xhejtman@ics.muni.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:27949 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750924AbXLCPVY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 3 Dec 2007 10:21:24 -0500
In-Reply-To: <20071203095023.GG26573@ics.muni.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lukas Hejtmanek wrote:
> On Tue, Nov 27, 2007 at 10:23:00AM -0800, Kok, Auke wrote:
>> can you see if your problem goes away with this patch?
> 
> I cannot test it right now but friend of mine has the same card with 2.6.23.1
> kernel. it does not. he also tried module 7.6.12 from source fourge, your patch
> did not help. Moreover, it just hangs network connections after while. No
> message in dmesg about hangup.

can you open up a ticket on e1000.sf.net and fill in a full bugreport including
output of all of these? :

- ethttool -i eth0
- ethtool -e eth0
- lspci -vv
- full dmesg (not just the driver parts)
- dmidecode
- cat /proc/interrupts

I'd like to see if maybe we can reproduce this in our lab.

Thanks,

Auke
