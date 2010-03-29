From: Michal Simek <michal.simek@petalogix.com>
Subject: Re: Network performance - iperf
Date: Mon, 29 Mar 2010 16:54:32 +0200
Message-ID: <4BB0BF28.5090505@petalogix.com>
References: <4BB09021.6020202@petalogix.com> <1269864994.2164.21.camel@edumazet-laptop>
Reply-To: michal.simek@petalogix.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org, Grant Likely <grant.likely@secretlab.ca>,
	John Linn <John.Linn@xilinx.com>,
	"Steven J. Magnani" <steve@digidescorp.com>,
	Arnd Bergmann <arnd@arndb.de>, akpm@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1269864994.2164.21.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> Le lundi 29 mars 2010 =C3=A0 13:33 +0200, Michal Simek a =C3=A9crit :
>=20
>> Do you have any idea howto improve TCP/UDP performance in general?
>> Or tests which can point me on weak places.
>=20
> Could you post "netstat -s" on your receiver, after fresh boot and yo=
ur
> iperf session, for 32 MB and 256 MB ram case ?
>=20

I am not sure if is helpful but look below.

Thanks,
Michal

~ # ./netstat -s
Ip:
     0 total packets received
     0 forwarded
     0 incoming packets discarded
     0 incoming packets delivered
     0 requests sent out
Icmp:
     0 ICMP messages received
     0 input ICMP message failed.
     ICMP input histogram:
     0 ICMP messages sent
     0 ICMP messages failed
     ICMP output histogram:
Tcp:
     0 active connections openings
     0 passive connection openings
     0 failed connection attempts
     0 connection resets received
     0 connections established
     0 segments received
     0 segments send out
     0 segments retransmited
     0 bad segments received.
     0 resets sent
Udp:
     0 packets received
     0 packets to unknown port received.
     0 packet receive errors
     0 packets sent
     RcvbufErrors: 0
     SndbufErrors: 0
UdpLite:
     InDatagrams: 0
     NoPorts: 0
     InErrors: 0
     OutDatagrams: 0
     RcvbufErrors: 0
     SndbufErrors: 0
error parsing /proc/net/snmp: Success



--=20
Michal Simek, Ing. (M.Eng)
PetaLogix - Linux Solutions for a Reconfigurable World
w: www.petalogix.com p: +61-7-30090663,+42-0-721842854 f: +61-7-3009066=
3
