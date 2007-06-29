From: Pierre Capillon <pierrecap@yahoo.fr>
Subject: Getting hopcount and dupacks from TCP CA module
Date: Fri, 29 Jun 2007 11:48:37 +0200 (CEST)
Message-ID: <20070629094837.92827.qmail@web25504.mail.ukl.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from web25504.mail.ukl.yahoo.com ([217.12.10.150]:47307 "HELO
	web25504.mail.ukl.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1754064AbXF2JzS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 05:55:18 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

I'm a french IT engineering student and as part of my
internship, I'm writing a congestion avoidance module
based on research by my tutor. It aims at better
efficiency and throughput on mobile adhoc networks.

Basically, it is a sender-side modification that
differentiates between losses due to network
congestion or link failure, in which case I would need
to get the new route properties for the current tcp
socket.

Is there a simple and generic way of knowing the route
length (hopcount) from a TCP CA module, once RTO has
occured? Currently, the paper states I should know the
exact new route length to recompute the congestion
window and RTO values. I guess I need to get that
information from the routing layers, but is it event
possible from the module? Or is it simpler to rework
the algorithm to have the congestion window based on
hop difference (using received TTL values from the
remote end)?

Either way, I would appreciate hints/pointers to
structures and/or mechanics I would not have properly
understood in congestion avoidance modules (especially
how to get down to the received IP header for received
TTL values or to the routing protocols).

Regarding dupacks, after a full week of studying the
code and another week of implementing most of the
principles described in the said paper, I would like
some confirmation : it seems like the field
tp->sacked_out is accounting for them in a SACKless
connection (in tcp_fastretrans_alert()). Can I without
a doubt rely on it to adjust TCP's behavior? If so,
can I check is the state is TCP_CA_Disorder and then
the value of sacked_out in order to adjust my behavior
once 3 duplicate acks have been received, or is there
a better way to do it?
I'm sorry if this sounds like a dumb question, but I
want to make sure, as I'm no expert.


Thanks a lot.



Pierre Capillon




=09
	=09
_______________________________________________________________________=
____=20
D=E9couvrez une nouvelle fa=E7on d'obtenir des r=E9ponses =E0 toutes vo=
s questions !=20
Profitez des connaissances, des opinions et des exp=E9riences des inter=
nautes sur Yahoo! Questions/R=E9ponses=20
http://fr.answers.yahoo.com
