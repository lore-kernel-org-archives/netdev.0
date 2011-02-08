From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 28282] New: forwarding turns
 autoconfiguration off
Date: Tue, 08 Feb 2011 13:44:21 -0800 (PST)
Message-ID: <20110208.134421.39185637.davem@davemloft.net>
References: <bug-28282-10286@https.bugzilla.kernel.org/>
	<20110208133408.7d447e6a.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, hadmut@danisch.de
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48435
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751831Ab1BHVnr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Feb 2011 16:43:47 -0500
In-Reply-To: <20110208133408.7d447e6a.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Morton <akpm@linux-foundation.org>
Date: Tue, 8 Feb 2011 13:34:08 -0800

>> Linux ethernet interfaces do not use autoconfiguration and do ignore router
>> advertisings if the packet forwarding is turned on in the configuration (i.e. 
>> /proc/sys/net/ipv6/conf/eth0/forwarding set to 1)
>> 
>> 
>> This might be wrong.
>> 
>> IPv6 network devices can have multiple IPv6 addresses and server several
>> purposes at the same time. A machine can have a statically assigned local IPv6
>> address and act as a router (e.g. to a virtual machine or a VPN tunnel) and
>> thus needs to turn forwarding on, while at the same time it needs to listen to
>> router advertisements and autoconfigure, e.g. because a network is connected to
>> the internet through a DSL router with dynamically assigned network adresses,
>> either through direct IPv6 assignment or a 6to4 tunnel. 
>> 
>> So there are cases where you need to have autoconfiguration of an IP address
>> and forwarding on the same interface at the same time. Therefore, it might be
>> technically wrong to have this mutually exclusive. 

This is a case where we're probably just following what the RFC documents
state we should do, which means unless you can provide clear reference to
a specification that states we should behave otherwise this isn't changing.
