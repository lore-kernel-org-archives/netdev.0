From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Large file copy to NFS mounted directory causes delay in other
 application packets
Date: Wed, 09 Nov 2011 07:24:35 +0100
Message-ID: <1320819875.26025.48.camel@edumazet-laptop>
References: <1320816503.73813.YahooMailNeo@web160718.mail.bf1.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Manavalan Krishnan <manavalan_k@yahoo.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1320816503.73813.YahooMailNeo@web160718.mail.bf1.yahoo.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 08 novembre 2011 =C3=A0 21:28 -0800, Manavalan Krishnan a =C3=A9=
crit :
> Hi All
>=20
> I have two systems with two network interfaces each(eth0 and eth1). I
> am running linux-HA (heartbeat deamon) on both the systems and they
> use eth0 for exchanging heartbeats. I have NFS mounted directory in
> one system and the NFS client uses the interface eth1.=20
>=20
> I try to copy a large file to NFS mounted directory. But the heartbea=
t
> daemons misses the heartbeat packets from peers while copy is under
> progress. I did tcpdump and found that the heartbeat packets are
> delayed for few seconds before sent out on eth0. When I stop the file
> copy, the heartbeats are delivered properly. It seems linux kernel
> somehow giving priority for NFS packets(generated from the file copy)
> over other application packets.
>=20
> Any thoughts on this behavior? Is there any way we can avoid this so
> that application packets get equal chance while large file copy to NF=
S
> mounted directory under progress?
>=20
CC netdev

1) Is your NFS using UDP or TCP ?
2) Is your eth0 dedicated to heartbeats and eth1 to NFS traffic ?
3) How do you know heartbeats are delayed ?
4) Is your server CPU bounded ?

Thanks
