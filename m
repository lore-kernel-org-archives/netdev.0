From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bad performance when CUBIC HyStart enabled
Date: Thu, 03 Mar 2011 18:46:23 +0100
Message-ID: <1299174383.2983.144.camel@edumazet-laptop>
References: <20110303142229.GA9262@xanadu.blop.info>
	 <1299164580.2983.99.camel@edumazet-laptop>
	 <20110303173733.GB8028@xanadu.blop.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Sangtae Ha <sha2@ncsu.edu>
To: Lucas Nussbaum <lucas.nussbaum@loria.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44706 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758483Ab1CCRqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2011 12:46:42 -0500
Received: by fxm17 with SMTP id 17so1334804fxm.19
        for <netdev@vger.kernel.org>; Thu, 03 Mar 2011 09:46:41 -0800 (PST)
In-Reply-To: <20110303173733.GB8028@xanadu.blop.info>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 03 mars 2011 =C3=A0 18:37 +0100, Lucas Nussbaum a =C3=A9crit :

> I had 6 successful transfers. There's the netstat -s output after the=
 5
> first successful transfers. Then the 7th transfer showed the problem,
> as well as the 8th and the 9th. There's the netstat -s output after e=
ach
> of them.

Its a bit strange : my 'netstat -s' are more verbose than yours :

 netstat -s
Ip:
    1033944 total packets received
    0 forwarded
    0 incoming packets discarded
    1033705 incoming packets delivered
    701852 requests sent out
    4 dropped because of missing route
    120 reassemblies required
    60 packets reassembled ok
    60 fragments received ok
    120 fragments created
Icmp:
    704 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 177
        timeout in transit: 117
        echo requests: 103
        echo replies: 307
    693 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 177
        echo request: 413
        echo replies: 103
IcmpMsg:
        InType0: 307
        InType3: 177
        InType8: 103
        InType11: 117
        OutType0: 103
        OutType3: 177
        OutType8: 413
Tcp:
    10526 active connections openings
    212 passive connection openings
    78 failed connection attempts
    300 connection resets received
    26 connections established
    969786 segments received
    690213 segments send out
    894 segments retransmited
    0 bad segments received.
    305 resets sent
Udp:
    43123 packets received
    4 packets to unknown port received.
    0 packet receive errors
    9570 packets sent
UdpLite:
TcpExt:
    877 TCP sockets finished time wait in fast timer
    23798 delayed acks sent
    10 delayed acks further delayed because of locked socket
    Quick ack mode was activated 598 times
    542574 packets directly queued to recvmsg prequeue.
    140834 bytes directly in process context from backlog
    45033318 bytes directly received in process context from prequeue
    646384 packet headers predicted
    81439 packets header predicted and directly queued to user
    24971 acknowledgments not containing data payload received
    189383 predicted acknowledgments
    2 times recovered from packet loss by selective acknowledgements
    3 congestion windows recovered without slow start by DSACK
    308 congestion windows recovered without slow start after partial
ack
    2 TCP data loss events
    3 timeouts after SACK recovery
    2 fast retransmits
    1 retransmits in slow start
    632 other TCP timeouts
    9 times receiver scheduled too late for direct processing
    587 DSACKs sent for old packets
    2 DSACKs sent for out of order packets
    417 DSACKs received
    130 connections reset due to unexpected data
    72 connections aborted due to timeout
    TCPDSACKIgnoredOld: 176
    TCPDSACKIgnoredNoUndo: 56
    TCPSackMerged: 5
    TCPSackShiftFallback: 4
    TCPDeferAcceptDrop: 106
IpExt:
    InNoRoutes: 5
    InMcastPkts: 35832
    OutMcastPkts: 1403
    InBcastPkts: 19536
    OutBcastPkts: 89
    InOctets: 787953535
    OutOctets: 113825814
    InMcastOctets: 4098542
    OutMcastOctets: 211245
    InBcastOctets: 1906912
    OutBcastOctets: 13625


