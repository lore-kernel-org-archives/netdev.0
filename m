From: "Ravinandan Arakali" <ravinandan.arakali@s2io.com>
Subject: Question about Bonding driver
Date: Fri, 10 Dec 2004 18:01:32 -0800
Message-ID: <002201c4df25$56afc3c0$3a10100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Leonid. Grossman \(E-mail\)" <leonid.grossman@s2io.com>,
        "Raghavendra. Koushik \(E-mail\)" <raghavendra.koushik@s2io.com>,
        <rapuru.sriram@s2io.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
We are facing the following problem with bonding driver with two 10-gigabit
ethernet cards.
Any help is appreciated.

Server:  AMD Opteron system with two 10-gigabit ethernet cards
Switch: Foundry FastIron 800
Clients: Two Opteron systems, each with one 10-gigabit card.

The two cards on the server were aggregated in 802.3ad mode(mode=4).
On the switch, the two ports are aggregated in LACP mode.
With single stream traffic per client, transmit throughput to one of the
clients
is 3Gbps and the other, 5.5Gbps.
When the two cards are aggregated we get a throughput of
7.9 Gbps(which is 93% of combined throughputs).
BTW, throughput is measured using nttcp tool.

The MAC address on one of the clients is set to an even address and the MAC
address on the other client to odd. This ensures that the traffic to the two
clients is being distributed by the bonding driver to the two cards in the
bond.
We also verified this using ping.

However, the problem is, when we have multiple streams per client,
throughput drops
and we notice continuous TCP retransmissions from the server.

Note that without bonding driver, even if we run multiple TCP streams per
client(each card on server in different subnet), there are no
retransmissions and the
throughput is very good.


Thanks,
Ravi
