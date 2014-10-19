From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: [GIT] Networking
Date: Sun, 19 Oct 2014 04:15:54 +0200
Message-ID: <20141019021554.GD22068@x4>
References: <20141018.001844.1317443518545745039.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: torvalds@linux-foundation.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20141018.001844.1317443518545745039.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 2014.10.18 at 00:18 -0400, David Miller wrote:
>=20
> Please pull, thanks a lot.

In file included from net/core/sock.c:140:0:
include/net/tcp.h: In function =E2=80=98tcp_v6_iif=E2=80=99:
include/net/tcp.h:738:32: error: =E2=80=98union <anonymous>=E2=80=99 ha=
s no member named =E2=80=98h6=E2=80=99
  return TCP_SKB_CB(skb)->header.h6.iif;
                                ^
scripts/Makefile.build:257: recipe for target 'net/core/sock.o' failed
make[2]: *** [net/core/sock.o] Error 1
scripts/Makefile.build:402: recipe for target 'net/core' failed
make[1]: *** [net/core] Error 2
Makefile:936: recipe for target 'net' failed
make: *** [net] Error 2

 =E2=94=82 Symbol: IPV6 [=3Dn]                                         =
                                                                       =
                                       =E2=94=82
 =E2=94=82 Type  : tristate                                            =
                                                                       =
                                     =E2=94=82
 =E2=94=82 Prompt: The IPv6 protocol                                   =
                                                                       =
                                     =E2=94=82
 =E2=94=82   Location:                                                 =
                                                                       =
                                     =E2=94=82
 =E2=94=82     -> Networking support (NET [=3Dy])                      =
                                                                       =
                                       =E2=94=82
 =E2=94=82       -> Networking options                                 =
                                                                       =
                                     =E2=94=82
 =E2=94=82         -> TCP/IP networking (INET [=3Dy])                  =
                                                                       =
                                       =E2=94=82
 =E2=94=82   Defined at net/ipv6/Kconfig:6                             =
                                                                       =
                                     =E2=94=82
 =E2=94=82   Depends on: NET [=3Dy] && INET [=3Dy]

--=20
Markus
