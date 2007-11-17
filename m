From: Jarek Poplawski <jarkao2@o2.pl>
Subject: Re: [PATCH] net/ipv4/arp.c: Fix arp reply when sender ip 0
Date: Sat, 17 Nov 2007 23:14:04 +0100
Message-ID: <473F67AC.5020306@o2.pl>
References: <cac0ab7d0711151340l1cc91a2dw5ebf36e166d16d7a@mail.gmail.com>	<20071115.152813.89410917.davem@davemloft.net>	<cac0ab7d0711160030w149c7a7s2db55ac56d0a05cc@mail.gmail.com>	<20071116.010548.94286711.davem@davemloft.net> <20071116142619.8746376e.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, the.sator@gmail.com,
	kuznet@ms2.inr.ac.ru, linux-kernel@vger.kernel.org,
	jmorris@namei.org, netdev@vger.kernel.org,
	akpm@linux-foundation.org
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:49746 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751736AbXKQWM6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 17 Nov 2007 17:12:58 -0500
In-Reply-To: <20071116142619.8746376e.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bill Fink wrote, On 11/16/2007 08:26 PM:
...

> Regarding the Target IP, RFC 826 says:
> 
> 	"The target protocol address is necessary in the request form
> 	of the packet so that a machine can determine whether or not
> 	to enter the sender information in a table or to send a reply.
> 	It is not necessarily needed in the reply form if one assumes
> 	a reply is only provoked by a request.  It is included for
> 	completeness, network monitoring, and to simplify the suggested
> 	processing algorithm described above (which does not look at
> 	the opcode until AFTER putting the sender information in a
> 	table).
> 
> So it's ambiguous about the target IP address in an ARP reply packet,
> but a value of 0.0.0.0 makes more logical sense to me than using
> 192.168.0.1 in this example case, since it should reflect the requestor
> IP address, which is unknown in this case.

IMHO, you are mostly right, but, according to this, if it's ambiguous
then only, if there is the target IP or no target IP, so here 0.0.0.0
or 0.0.0.0...

Regards,
Jarek P.
