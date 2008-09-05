From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: Channel bonding with e1000
Date: Fri, 05 Sep 2008 07:37:33 -0700
Message-ID: <15938.1220625453@death.nxdomain.ibm.com>
References: <48C0EF8A.9070103@aei.mpg.de>
Cc: netdev@vger.kernel.org
To: Carsten Aulbert <carsten.aulbert@aei.mpg.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e6.ny.us.ibm.com ([32.97.182.146]:57443 "EHLO e6.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754198AbYIEOhy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Sep 2008 10:37:54 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e6.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m85EeLR0002336
	for <netdev@vger.kernel.org>; Fri, 5 Sep 2008 10:40:21 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.0) with ESMTP id m85EbbY2194550
	for <netdev@vger.kernel.org>; Fri, 5 Sep 2008 10:37:37 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m85EbaVS016856
	for <netdev@vger.kernel.org>; Fri, 5 Sep 2008 10:37:37 -0400
In-reply-to: <48C0EF8A.9070103@aei.mpg.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Carsten Aulbert <carsten.aulbert@aei.mpg.de> wrote:
[...]
>On a few data servers we intend to do channel bonding. The boxes have
>two NICs on the motherboard and two extra ones on an expansion card:
>
>04:00.0 Ethernet controller: Intel Corporation 631xESB/632xESB DPT LAN
>Controller Copper (rev 01)
>04:00.1 Ethernet controller: Intel Corporation 631xESB/632xESB DPT LAN
>Controller Copper (rev 01)
>05:02.0 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
>Controller (rev 03)
>05:02.1 Ethernet controller: Intel Corporation 82546GB Gigabit Ethernet
>Controller (rev 03)
>
>My simple question would be: Does it matter which two ports I can use to
>channel together when using in a set-up with MTU=9000?

	Nope.

	If you're concerned about tolerance to failure, you may want to
pick one port from each (one built-in port, one from the card) so if the
expansion card dies you're not totally cut off.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
