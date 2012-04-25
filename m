From: "Dave, Tushar N" <tushar.n.dave@intel.com>
Subject: RE: rx_dropped packets stop with tcpdump running
Date: Wed, 25 Apr 2012 18:19:30 +0000
Message-ID: <061C8A8601E8EE4CA8D8FD6990CEA891180CC211@ORSMSX102.amr.corp.intel.com>
References: <DUB108-W3E0658169335663BE7574B23D0@phx.gbl>
	<1334841865.2395.177.camel@edumazet-glaptop>
	<1334842088.2395.178.camel@edumazet-glaptop>
	<061C8A8601E8EE4CA8D8FD6990CEA8910FF2D23F@ORSMSX102.amr.corp.intel.com>
	<DUB108-W45246BF22ED8BAB93B78C8B2220@phx.gbl>	<4F9179E3.5020507@hp.com>
	<DUB108-W57C2F8FCF145C20E3B8BF1B2220@phx.gbl>
 <20120422011354.623b08d4.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "brian.haley@hp.com" <brian.haley@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
	Bill Fink <billfink@mindspring.com>
To: Marco Berizzi <pupilla@hotmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:54172 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752006Ab2DYSTm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 14:19:42 -0400
In-Reply-To: <20120422011354.623b08d4.billfink@mindspring.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>-----Original Message-----
>From: Bill Fink [mailto:billfink@mindspring.com]
>Sent: Saturday, April 21, 2012 10:14 PM
>To: Marco Berizzi
>Cc: brian.haley@hp.com; Dave, Tushar N; netdev@vger.kernel.org;
>eric.dumazet@gmail.com
>Subject: Re: rx_dropped packets stop with tcpdump running
>
>On Fri, 20 Apr 2012 17:25:28 +0200, Marco Berizzi wrote:
>
>> brian.haley@hp.com wrote:
>> > 0x886d or 0x86DD? That second one is IPv6, you might just need to =
load
>the module.
>>
>> here is the tcpdump:
>>
>> 17:23:25.561398 00:19:99:90:ba:72 > ff:ff:ff:ff:ff:ff, ethertype Unk=
nown
>(0x886d), length 64:
>> =A0=A0=A0=A0=A0=A0=A0 0x0000:=A0 0001 0001 000c 24e2 0001 0019 9990 =
ba72
>> ......$........r
>> =A0=A0=A0=A0=A0=A0=A0 0x0010:=A0 0000 0500 2304 6364 726f 447b d700 =
80f8
>....#.cdroD{....
>> =A0=A0=A0=A0=A0=A0=A0 0x0020:=A0 ffff 20d1 b631 80fa ffff e02b fb30 =
80fa
>.....1.....+.0..
>> =A0=A0=A0=A0=A0=A0=A0 0x0030:=A0 ffff=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 ..
>> 17:23:25.561402 00:19:99:90:ba:73 > ff:ff:ff:ff:ff:ff, ethertype Unk=
nown
>(0x886d), length 64:
>> =A0=A0=A0=A0=A0=A0=A0 0x0000:=A0 0001 0001 000c 24e2 0002 0019 9990 =
ba72
>> ......$........r
>> =A0=A0=A0=A0=A0=A0=A0 0x0010:=A0 6700 5400 6800 7200 6500 7300 6800 =
6f00
>g.T.h.r.e.s.h.o.
>> =A0=A0=A0=A0=A0=A0=A0 0x0020:=A0 6c00 6400 0000 3700 3200 0000 0000 =
0000
>l.d...7.2.......
>> =A0=A0=A0=A0=A0=A0=A0 0x0030:=A0 0000=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0 ..
>
>FYI, a Google search for "ethertype 886d" revealed that this is suppos=
edly
>an Intel ANS probe.  See:
>
>  http://fixunix.com/networking/337443-packets-broadcasting-every-
>second.html
>
>						-Bill


Marco,

Looking at the eeprom dump you provided, looks like this issue may get =
fixed by eeprom update.
Would you please try eeprom update script, fixeep-82574_83.sh , from
https://sourceforge.net/projects/e1000/files/e1000e%20stable/eeprom_fix=
_82574_or_82583/

-Tushar
