From: Troy Wilson <tcw@tempest.prismnet.com>
Subject: Re: Early SPECWeb99 results on 2.5.33 with TSO on e1000
Date: Fri, 6 Sep 2002 18:56:04 -0500 (CDT)
Sender: linux-kernel-owner@vger.kernel.org
Message-ID: <200209062356.g86Nu4Gk016944@tempest.prismnet.com>
References: <Pine.GSO.4.30.0209051648020.17973-100000@shell.cyberus.ca>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+linux-kernel=40quimby.gnus.org@vger.kernel.org>
In-Reply-To: <Pine.GSO.4.30.0209051648020.17973-100000@shell.cyberus.ca>
 "from jamal at Sep 5, 2002 04:59:47 pm"
To: jamal <hadi@cyberus.ca>
List-Id: netdev.vger.kernel.org

> Do you have any stats from the hardware that could show
> retransmits etc;

**********************************
* netstat -s before the workload *
**********************************

Ip:
    433 total packets received
    0 forwarded
    0 incoming packets discarded
    409 incoming packets delivered
    239 requests sent out
Icmp:
    24 ICMP messages received
    0 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 24
    24 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 24
Tcp:
    0 active connections openings
    2 passive connection openings
    0 failed connection attempts
    0 connection resets received
    2 connections established
    300 segments received
    183 segments send out
    0 segments retransmited
    0 bad segments received.
    2 resets sent
Udp:
    8 packets received
    24 packets to unknown port received.
    0 packet receive errors
    32 packets sent
TcpExt:
    ArpFilter: 0
    5 delayed acks sent
    4 packets directly queued to recvmsg prequeue.
    35 packets header predicted
    TCPPureAcks: 5
    TCPHPAcks: 160
    TCPRenoRecovery: 0
    TCPSackRecovery: 0
    TCPSACKReneging: 0
    TCPFACKReorder: 0
    TCPSACKReorder: 0
    TCPRenoReorder: 0
    TCPTSReorder: 0
    TCPFullUndo: 0
    TCPPartialUndo: 0
    TCPDSACKUndo: 0
    TCPLossUndo: 0
    TCPLoss: 0
    TCPLostRetransmit: 0
    TCPRenoFailures: 0
    TCPSackFailures: 0
    TCPLossFailures: 0
    TCPFastRetrans: 0
    TCPForwardRetrans: 0
    TCPSlowStartRetrans: 0
    TCPTimeouts: 0
    TCPRenoRecoveryFail: 0
    TCPSackRecoveryFail: 0
    TCPSchedulerFailed: 0
    TCPRcvCollapsed: 0
    TCPDSACKOldSent: 0
    TCPDSACKOfoSent: 0
    TCPDSACKRecv: 0
    TCPDSACKOfoRecv: 0
    TCPAbortOnSyn: 0
    TCPAbortOnData: 0
    TCPAbortOnClose: 0
    TCPAbortOnMemory: 0
    TCPAbortOnTimeout: 0
    TCPAbortOnLinger: 0
    TCPAbortFailed: 0
    TCPMemoryPressures: 0

*********************************
* netstat -s after the workload *
*********************************

Ip:
    425317106 total packets received
    3648 forwarded
    0 incoming packets discarded
    425313332 incoming packets delivered
    203629600 requests sent out
Icmp:
    58 ICMP messages received
    12 input ICMP message failed.
    ICMP input histogram:
        destination unreachable: 58
    58 ICMP messages sent
    0 ICMP messages failed
    ICMP output histogram:
        destination unreachable: 58
Tcp:
    64 active connections openings
    16690445 passive connection openings
    56552 failed connection attempts
    0 connection resets received
    3 connections established
    425311551 segments received
    203629500 segments send out
    4241408 segments retransmited
    0 bad segments received.
    298883 resets sent
Udp:
    8 packets received
    34 packets to unknown port received.
    0 packet receive errors
    42 packets sent
TcpExt:
    ArpFilter: 0
    8884840 TCP sockets finished time wait in fast timer
    12913162 delayed acks sent
    17292 delayed acks further delayed because of locked socket
    Quick ack mode was activated 102351 times
    54977 times the listen queue of a socket overflowed
    54977 SYNs to LISTEN sockets ignored
    157 packets directly queued to recvmsg prequeue.
    51 packets directly received from prequeue
    16925947 packets header predicted
    51 packets header predicted and directly queued to user
    TCPPureAcks: 169071816
    TCPHPAcks: 176510836
    TCPRenoRecovery: 30090
    TCPSackRecovery: 0
    TCPSACKReneging: 0
    TCPFACKReorder: 0
    TCPSACKReorder: 0
    TCPRenoReorder: 464
    TCPTSReorder: 5
    TCPFullUndo: 6
    TCPPartialUndo: 29
    TCPDSACKUndo: 0
    TCPLossUndo: 1
    TCPLoss: 0
    TCPLostRetransmit: 0
    TCPRenoFailures: 218884
    TCPSackFailures: 0
    TCPLossFailures: 35561
    TCPFastRetrans: 145529
    TCPForwardRetrans: 0
    TCPSlowStartRetrans: 3463096
    TCPTimeouts: 373473
    TCPRenoRecoveryFail: 1221
    TCPSackRecoveryFail: 0
    TCPSchedulerFailed: 0
    TCPRcvCollapsed: 0
    TCPDSACKOldSent: 0
    TCPDSACKOfoSent: 0
    TCPDSACKRecv: 1
    TCPDSACKOfoRecv: 0
    TCPAbortOnSyn: 0
    TCPAbortOnData: 0
    TCPAbortOnClose: 0
    TCPAbortOnMemory: 0
    TCPAbortOnTimeout: 0
    TCPAbortOnLinger: 0
    TCPAbortFailed: 0
    TCPMemoryPressures: 0
