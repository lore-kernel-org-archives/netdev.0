From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: no_arp
Date: Fri, 26 Apr 2002 20:11:45 +0200 (MET DST)
Sender: owner-netdev@oss.sgi.com
Message-ID: <Pine.GSO.4.05.10204262005360.25945-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <owner-netdev@oss.sgi.com>
To: netdev@oss.sgi.com
List-Id: netdev.vger.kernel.org

hi list,

is there a way to disable dynamic ARP on a specific interface
during runtime. (i looked around the kernel sources, but must
have missed it)

'ifconfig eth? noarp' disables dynamic ARPing, but it also
	seems to prevent writing to the ARP table itself
	(and don't consult the ARP table at all)
	- which is fine and the behaviour i would expect.

why i would like to have this feature nevertheless?

well, i would consider having a static ARP table better for
certain networks (networks which are heavily frequented by
people who want to "experiment") - this makes our host
resistent to ARP poisoning (ok, we won't be standard conform,
that's why i'd like to be able to control the behaviour 
on runtime :)

thanks for your help,

	++dent

-- 
in some way i do, and in some way i don't.
