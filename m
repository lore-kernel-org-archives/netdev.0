From: Shlomo Pongartz <shlomop@mellanox.com>
Subject: GRO aggregation
Date: Tue, 11 Sep 2012 16:45:07 +0300
Message-ID: <504F4063.9030706@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog111.obsmtp.com ([207.126.144.131]:39851 "HELO
	eu1sys200aog111.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751906Ab2IKNqX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Sep 2012 09:46:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I=92m checking GRO aggregation with kernel 3.6.0-rc1+ using Intel ixgbe=
=20
driver.
The mtu is 1500 and GRO is on and so are SG and RX checksum.
I ran iperf with default setting and monitor the receiver with tcpdump.
The tcpdump shows that the maximal aggregation is 32120 which is 21 * 1=
500.
In the transmitter side tcpdump shows that TSO works better (~64K).
I did a capture without GRO enabled to see if there was a difference=20
between any flag
of any two consecutive packets that forced flushing but didn't find=20
anything.
Is the GRO aggregation can be tuned.



Shlomo Pongratz
