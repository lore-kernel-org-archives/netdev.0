From: "Ravinandan Arakali" <ravinandan.arakali@neterion.com>
Subject: High CPU utilization with Bonding driver ?
Date: Tue, 29 Mar 2005 10:22:19 -0800
Message-ID: <001601c5348c$3f417f50$3a10100a@pc.s2io.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: "Leonid. Grossman \(E-mail\)" <leonid.grossman@neterion.com>,
        "Raghavendra. Koushik \(E-mail\)" <raghavendra.koushik@neterion.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: <netdev@oss.sgi.com>, <bonding-devel@lists.sourceforge.net>
In-Reply-To: 
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,
We are facing the following problem with bonding driver with two 10-gigabit
ethernet cards.
Any help is greatly appreciated.

Configuration:
--------------
Server:  Four processor AMD Opteron running 2.6.5 kernel
Switch:  Foundry stackable switch
Clients: Two Opteron systems, each with one 10-gigabit card.
Bonding: Two 10G cards bonded in LACP mode. One card in 133 MHz slot,
         the other in 100 MHz slot(though we suspect the latter is scaling
         down to 66 MHz)

Results(8 nttcp/chariot streams):
---------------------------------
1. Combined throughputs(but no bonding):
3.1 + 6.2 = 9.3 Gbps with 58% CPU idle.

2. eth0 and eth1 bonded together in LACP mode:
8.2 Gbps with 1% CPU idle.

>From the above results, when Bonding driver is used(#2), the CPUs are
completely maxed out compared to the case when traffic is run
simultaneously on both the cards(#1).
Can anybody suggest some reasons for the above behavior ?

Thanks,
Ravi
