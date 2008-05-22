From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Fwd: [Bug 447812] New: Netlink messages from "tc" to sch_netem
 module are not interpreted correctly
Date: Wed, 21 May 2008 17:57:34 -0700
Message-ID: <4834C4FE.4060502@hp.com>
References: <20080521214523.GB22591@codemonkey.org.uk>	<20080521151021.3d47a3d8@extreme> <20080522002155.GP20815@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Dave Jones <davej@codemonkey.org.uk>, netdev@vger.kernel.org
To: Thomas Graf <tgraf@suug.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:18601 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755385AbYEVA5h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 May 2008 20:57:37 -0400
In-Reply-To: <20080522002155.GP20815@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> Could you try this patch?

I'm not sure what it does to the tc case, unless I botched applying the 
patch, my rtnetlink case doesn't seem to change:

izzy:~/netperf2_trunk# ./testfoo 16.89.133.212
destination address is 16.89.133.212
egress interface 0x6000000000004010 eth6
izzy:~/netperf2_trunk# ./testfoo 16.89.133.212 10.208.0.17
netlink: 8 bytes leftover after parsing attributes.
destination address is 16.89.133.212
egress interface 0x6000000000004010 eth6
izzy:~/netperf2_trunk# uname -a
Linux izzy 2.6.26-rc1-netlink #1 SMP Wed May 21 17:36:53 PDT 2008 ia64 
GNU/Linux

rick jones

