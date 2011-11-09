From: Manavalan Krishnan <manavalan_k@yahoo.com>
Subject: Re: Large file copy to NFS mounted directory causes delay in other application packets
Date: Wed, 9 Nov 2011 00:42:31 -0800 (PST)
Message-ID: <1320828151.17101.YahooMailNeo@web160705.mail.bf1.yahoo.com>
References: <1320816503.73813.YahooMailNeo@web160718.mail.bf1.yahoo.com> <1320819875.26025.48.camel@edumazet-laptop> <CAA93jw4gDuHyG508zxRzyn+MJ4gL5m958OaCWJxoDsaLgjdnqg@mail.gmail.com>
Reply-To: Manavalan Krishnan <manavalan_k@yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>
To: Dave Taht <dave.taht@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAA93jw4gDuHyG508zxRzyn+MJ4gL5m958OaCWJxoDsaLgjdnqg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

>When I see behavior like this I keep thinking interactions between ove=
rlarge large txqueuelens, somewhat busted TCP offloads on NICs, and tha=
t pfifo_fast must die in favor of fair queuing and/or diffserv classifi=
cation. But seeing >it on two different nics implies that your switch (=
which I assume is shared) is possibly to blame...
>(I see bufferbloat everywhere, but mostly because it's what I work on)

>Is this NFS over TCP? Does the HA daemons prioritize packets at all? D=
oes your switch? Does your qdiscs? How deep are your buffers on the net=
work cards and txqueuelens and switch?=20
>(eric's other questions below are probably more valid)


HA=A0  daemons does not prioritize. could you please provide info on ho=
w to prioritize application packets?
We tried with different switches, the same problem occurs. so switch ma=
y not be the issue here.
switch and qdisks does not prirotize the packets.
Here are network buffers used in the servers

txqueuelen is 1000=20

net.core.netdev_max_backlog =3D 1000
net.core.rmem_default =3D 262144
net.core.rmem_max =3D 262144
net.core.wmem_default =3D 129024
net.core.wmem_max =3D 131071
net.ipv4.tcp_rmem =3D 4096=A0=A0=A0 87380=A0=A0=A0 4194304
net.ipv4.tcp_wmem =3D 4096=A0=A0=A0 16384=A0=A0=A0 4194304
net.ipv4.tcp_mem =3D 196608=A0=A0=A0 262144=A0=A0=A0 393216

Thanks
