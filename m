From: =?ISO-8859-2?Q?Micha=B3_Margula?= <alchemyx@uznam.net.pl>
Subject: Re: Fw: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups
Date: Tue, 16 Nov 2004 11:16:09 +0100
Message-ID: <4199D369.8030708@uznam.net.pl>
References: <20041115122046.1413527e.akpm@osdl.org>	<200411152146.02851.bdschuym@pandora.be> <20041115124843.4c3dd72f.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Bart De Schuymer <bdschuym@pandora.be>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andrew Morton <akpm@osdl.org>
In-Reply-To: <20041115124843.4c3dd72f.akpm@osdl.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Andrew Morton napisa=B3(a):

>>>The only weird thing I noticed is when I initalise my bridge, is somet=
hing
>>>about that it can't get speed of some interfaces (guessing it is about
>>>e1000). I can't give you full error message at the moment, because tho=
se
>>>have been rotated by logrotate.
>>>     =20
>>>
>>I don't know what that is about...
>>   =20
>>
>
You can ignore error about problems with decoding speed on interface.=20
Found source of that. It happens when one of my network cards has cable=20
unplugged. In that case it gets weird numbers (same thing happens with=20
ethtool).

About main problem - it has been about 13 hours since changing rules to=20
iptables and nothing happened. We need to wait until tomorrow, to be=20
completly sure.

--=20
Micha=B3 Margula, alchemyx@uznam.net.pl, http://alchemyx.uznam.net.pl/
"W =BFyciu pi=EAkne s=B1 tylko chwile" [Ryszard Riedel]
