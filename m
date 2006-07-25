From: "Piotrowski, Ted P." <Ted.Piotrowski@jhuapl.edu>
Subject: bandwidth limitation help
Date: Tue, 25 Jul 2006 16:42:27 -0400
Message-ID: <3C5BFF28444F434695FB134004DF014701B94425@aplesjustice.dom1.jhuapl.edu>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from APLesJustice.dom1.jhuapl.edu ([128.244.198.158]:40024 "EHLO
	aplesjustice.dom1.jhuapl.edu") by vger.kernel.org with ESMTP
	id S1751573AbWGYUm1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 16:42:27 -0400
Content-class: urn:content-classes:message
To: <netdev@vger.kernel.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
 
I am new to the mailing list so I'm not sure if anybody reads these, but
here goes nothing. I recently read: Linux Advanced Routing & Traffic
Control HOWTO and have been trying to test my applications using
bandwidth limitation. All the examples described in the HOWTO do not
simulate the conditions I need to test my software. What I would like is
for my bandwidth limitation to empty my UDP buffer at a given rate. I
have tried using a simple TBF to do this, but all that happens is that
my application floods the TBF buffer at link speed and the TBF buffer
quickly overflows and drops packets. I want the packets to actually stay
in the UDP buffer and be emptied at a given rate without modifying my
application.
 
I don't know if any of you are familiar with netem, but it can be used
in conjuction with tc to add delay to a link. Surprisingly, packets
delayed by netem appear to remain in the UDP buffer until it is time for
them to be sent. I would like this same behavior of keeping the packets
in the UDP buffer, but with bandwidth limitation on the rate at which
the buffer empties, not just packet delay. Has anybody ever done
anything like this or can point me to some resources?
 
Thank you,
Ted P.
