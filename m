From: Joerg Pommnitz <pommnitz@yahoo.com>
Subject: AW: Does tc-prio really work as advertised?
Date: Tue, 27 Nov 2007 05:00:55 -0800 (PST)
Message-ID: <759014.71791.qm@web51409.mail.re2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from web51409.mail.re2.yahoo.com ([206.190.38.188]:28571 "HELO
	web51409.mail.re2.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754872AbXK0NA5 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 27 Nov 2007 08:00:57 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> So, are you still sure you've tested such a case?

Well, the problem that triggered my investigation was
that the OLSR daemon (www.olsr.org) calculates the quality
of a link according to the packet loss for LQ HELLO packets
(UDP broadcast packets). To prevent other traffic from
interfering with the LQ calculation, olsrd sends the HELLO
packets with a TOS value of 0x10 (minimize delay). This
should give them the highest priority.

What I saw was a degrading Link quality with more user traffic
over a link. The LQ fell so far that olsrd judged the other host
unreachable and deleted the routing entry. The user traffic in
question was iperf (TOS value 0x00).

The OLSR traffic was obviously generated locally (not forwarded).
You claim, that the TOS value for locally generated traffic does
not influence its priority?

Now I THINK that I did my tests both, for forwarded and for
local traffic, but I'll redo my tests to make sure.

 
--  
Regards and thanks for taking an interest

 
       Joerg




        __________________________________  Ihr erstes Baby? Holen Sie sich Tipps von anderen Eltern.  www.yahoo.de/clever
