From: Marc.Obbad@smsc.com
Subject: rstp for 2.4 kernel: port state keeps changing
Date: Fri, 9 Mar 2007 12:24:40 -0500
Message-ID: <OFDA8BE66A.E9965C39-ON85257299.005EA6D8-85257299.005FA4F5@smsc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
To: netdev@vger.kernel.org, bridge@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.smsc.com ([170.129.50.11]:3136 "EHLO smsc.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752692AbXCIRZB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Mar 2007 12:25:01 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

I am using RSTP for 2.4 kernel.

I have created a loop between two bridges:

                   P1  -----------------------------------  P1
BR1                                                                                BR2
                   P2  ----------------------------------   P2


BR2  is rinning linux bridge RSTP.

BR1 is a Root running STP ( Netgear switch).

The port P2 on BR2 go to Blocking state for a while, then  got to Listening state, learning State, Forwarding state and
then back to Blocking State.
The same thing happen over and over.

Any help is appreciated.


Regrads,

-Marc.

