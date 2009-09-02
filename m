From: Aras Vaichas <arasv@magellan-technology.com>
Subject: Re: 100Mbit ethernet performance on embedded devices
Date: Wed, 2 Sep 2009 15:09:05 +1000
Message-ID: <ed62800909012209vb4d32bcp9d43f1bdd837de6b@mail.gmail.com>
References: <20090819145057.GA25400@sig21.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-embedded@vger.kernel.org, netdev@vger.kernel.org
To: Johannes Stezenbach <js@sig21.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog110.obsmtp.com ([74.125.149.203]:34886 "HELO
	na3sys009aog110.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755717AbZIBFQx convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Sep 2009 01:16:53 -0400
In-Reply-To: <20090819145057.GA25400@sig21.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 20, 2009 at 12:50 AM, Johannes Stezenbach <js@sig21.net> wr=
ote:
>
> Hi,
>
> a while ago I was working on a SoC with 200MHz ARM926EJ-S CPU
> and integrated 100Mbit ethernet core, connected on internal
> (fast) memory bus, with DMA. =A0With iperf I measured:
>
> =A0TCP RX ~70Mbit/sec =A0(iperf -s on SoC, iperf -c on destop PC)
> =A0TCP TX ~56Mbit/sec =A0(iperf -s on destop PC, iperf -c o SoC)
>
> What I'm interested in are some numbers for similar hardware,
> to find out if my hardware and/or ethernet driver can be improved,
> or if the CPU will always be the limiting factor.
> I'd also be interested to know if hardware checksumming
> support would improve throughput noticably in such a system,
> or if it is only useful for 1Gbit and above.
>
> Did anyone actually manage to get close to 100Mbit/sec
> with similar CPU resources?

No, but I can share results.

AT91RM9200 (ARM920T), 180MHz
Davicom 9161 PHY
Linux 2.6.26.3

CONFIG_NETFILTER=3Dy
CONFIG_NETFILTER_ADVANCED=3Dy

# uptime; iperf -s; uptime
=A000:07:33 up 7 min, load average: 0.02, 0.10, 0.07
------------------------------------------------------------
Server listening on TCP port 5001
TCP window size: 85.3 KByte (default)
------------------------------------------------------------
[=A0 4] local 169.254.0.235 port 5001 connected with 169.254.0.2 port 5=
0762
[ ID] Interval=A0=A0=A0=A0=A0=A0 Transfer=A0=A0=A0=A0 Bandwidth
[=A0 4]=A0 0.0-10.0 sec=A0 58.6 MBytes=A0 49.1 Mbits/sec

=A000:07:46 up 7 min, load average: 0.17, 0.13, 0.08
