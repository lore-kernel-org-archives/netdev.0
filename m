From: =?iso-8859-2?Q?Pawe=B3_Soko=B3owski?= <falcon@muflon.linux.pl>
Subject: Re: 2.6.4-rc1 + hp100 EISA, not working
Date: Fri, 5 Mar 2004 01:07:13 +0100 (CET)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.58.0403050059020.25624@don.falconne.eu.org>
References: <Pine.LNX.4.58.0402292149230.25624@don.falconne.eu.org>
 <wrpk724yicq.fsf@hina.wild-wind.fr.eu.org> <20040303122541.4dbcf0fc@dell_ss3.pdx.osdl.net>
 <Pine.LNX.4.58.0403040550150.25624@don.falconne.eu.org>
 <20040304092650.2575fd1c@dell_ss3.pdx.osdl.net>
Reply-To: pawel.sokolowski@muflon.linux.pl
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=iso-8859-2
Content-Transfer-Encoding: quoted-printable
Cc: mzyngier@freesurf.fr, netdev@oss.sgi.com, jgarzik@pobox.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20040304092650.2575fd1c@dell_ss3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I've seen things you people wouldn't believe. You writing:

>> eisa_bus_match dev sig=3D'HWPC061' state=3D0x1 eids=3DHWPF180
>> eisa_bus_match dev sig=3D'HWP1940' state=3D0x3 eids=3DHWPF180
>> without:
>> eisa_bus_match dev sig=3D'HWPC061' state=3D0x1 eids=3DHWPF180
>> eisa_bus_match dev sig=3D'HWP1940' state=3D0x0 eids=3DHWPF180
>> when modprobing hp100.
>The name HWP1940 is in the table, so that looks okay.
>Can you build with HP100_DEBUG defined?

OK. I builded module from 2.6.4-rc2 with HP100_DEBUG defined.

During compilation:

drivers/net/hp100.c: In function `hp100_eisa_probe':
drivers/net/hp100.c:2875: warning: unsigned int format, long unsigned int=
 arg (arg 3)
drivers/net/hp100.c: In function `hp100_module_init':
drivers/net/hp100.c:3066: warning: label `out3' defined but not used
drivers/net/hp100.c: At top level:
drivers/net/hp100.c:2806: warning: `hp100_RegisterDump' defined but not u=
sed

after modprobe hp100 I'm getting just:

bus eisa: add driver hp100

nothing more (I added CONFIG_DEBUG_DRIVER to kernel config).

The same on 2.6.4-rc1 (without any message after loading module).

--=20
  ,d$$$$$P.d$$b     d$P  ,gd$$$$$,gd$$$$g. ,$$$b._$$P               RLU #=
172534
  ggggggggggggg.   ggs  ,gg     ,gg    ,gg ggp,ggggg           Pawe=B3 So=
ko=B3owski
 d$P""""'""""Y$$. d$P   d$P     d$P   ,d$Pd$P `Y$$P      falcon@muflon.li=
nux.pl
d$P           Y$$d$$$$$P`Y$$$$$'`Y$$$$$P'd$P   d$P    Replicant (M) Des: =
Falcon
