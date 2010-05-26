From: Scott Feldman <scofeldm@cisco.com>
Subject: [RFC] IFLA_PORT_* iproute2 cmd line
Date: Tue, 25 May 2010 20:19:42 -0700
Message-ID: <C821E15E.35236%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Arnd Bergmann <arnd@arndb.de>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-1.cisco.com ([171.71.176.70]:10696 "EHLO
	sj-iport-1.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932105Ab0EZDTs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 23:19:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I need to provide an iproute2 patch for IFLA_PORT_* and I wanted to hash out
the cmd line before I submit it.  Here's what I think would work based on
previous input from Arnd:

Usage:  ip port associate DEVICE [ vf NUM ] {PROFILE|VSI}
        ip port pre-associate DEVICE [ vf NUM ] VSI
        ip port pre-associate-rr DEVICE [ vf NUM ] VSI
        ip port dis-associate DEVICE [ vf NUM ]
        ip port show [ DEVICE [ vf NUM ] ]

        PROFILE := port-profile PORT-PROFILE
                   [ instance-uuid INSTANCE-UUID ]
                   [ host-uuid HOST-UUID ]

        VSI := vsi managerid MGR typeid VTID typeidversion VER
               [ instance-uuid INSTANCE-UUID ]

Comments?

-scott

