From: linux lover <linux.lover2004@gmail.com>
Subject: tcp sequence no. query
Date: Sat, 25 Dec 2004 10:48:18 +0530
Message-ID: <72c6e37904122421186c8d4d67@mail.gmail.com>
Reply-To: linux lover <linux.lover2004@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,
I am anyalysing tcp sequence no.s on single pc by running TCP socket
program on ethernet card with ip 192.168.1.200. For that i added debug
messages in tcp_v4_rcv and also in tcp_transmit_skb to check what seq.
no. are used by kenrel 2.4.24. What results i found by doing dmesg on
console is that

-----------OUTPUT INTERFACE FOR TCP PACKET CONNECT----------
TCP_CONNECT
After push tcp header in tcp_transmit_skb th->seq=-745717026
After push tcp header in tcp_transmit_skb th->ack_seq=0
After pull tcp header in tcp_v4_rcv th->seq=-745717026
After pull tcp header in tcp_v4_rcv th->ack_seq=0

But that is happening once in 10 times. Why am i got above -ve seq.no. results?
regards,
linux.lover
