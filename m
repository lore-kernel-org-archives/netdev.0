From: =?ISO-8859-1?Q?Ra=FAl_Hern=E1ndez?= <rauhersu@gmail.com>
Subject: QoS hot changes changes (tc)
Date: Fri, 26 Jun 2009 15:19:27 +0200
Message-ID: <3f847c820906260619g238b6a17ub17af3f27da83ef5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.159]:44088 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbZFZNTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Jun 2009 09:19:25 -0400
Received: by fg-out-1718.google.com with SMTP id e12so37421fga.17
        for <netdev@vger.kernel.org>; Fri, 26 Jun 2009 06:19:27 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi there,

I am trying to characterize the situation in which we perform a change
in the shaping done by the Linux kernel (tc+qdisc), specifically when
modifying the bandwidth as a hot change while shaping with a previous
bw value. The system I am describing performs shaping per stream
(uplink and/or dowinlink or total), just marking the TOS of the ip
packet and provisioning the kernel via 'tc' to shape the packets.

My question is whether someone has tried to modify bw parameters, ie:
move from 90 to 45 kb/s while the queues are already being populated
with trafffic .Do not know if the shaper algorithm is able to adjust
the bw without service disruption/experiment transitory behavior as I
guess the algorithm must have some kind of feedback which depends of
the bytes already shaped and the value of the bw itself (ie: leaky
bucket).

Any experience with this kind of changes :-) ? Thx !

Raul

-- 
"We cannot change the cards we are dealt, just how we play the hand".
