From: "Thomas 'Dent' Mirlacher" <dent@cosy.sbg.ac.at>
Subject: ARPHRD_*
Date: Thu, 11 Apr 2002 12:45:10 +0200 (MET DST)
Sender: linux-net-owner@vger.kernel.org
Message-ID: <Pine.GSO.4.05.10204111239400.18455-100000@mausmaki.cosy.sbg.ac.at>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Return-path: <linux-net-owner@vger.kernel.org>
To: linux-net@vger.kernel.org
List-Id: netdev.vger.kernel.org

hi list,

i'm a little bit confused with the handling of dev->type.

tcpdump (just an example) uses dev->type to decide which
MAC header to parse, on the other hand, the kernel also uses
dev->type to construct ARPs ... and there are some 'hacks'
in there for other MAC layer protocols which need to have 
other hard_types than dev->type.

so wouldn't it be cleaner to add dev->arp_type, to use for
ARPs (whereas dev->type will specify the MAC?)

	tm
-- 
in some way i do, and in some way i don't.

