From: =?ISO-8859-2?Q?Micha=B3_Margula?= <alchemyx@uznam.net.pl>
Subject: Re: Fw: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups
Date: Mon, 15 Nov 2004 22:57:50 +0100
Message-ID: <4199265E.7030404@uznam.net.pl>
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

>Originator added to Cc..
>
>Bart De Schuymer <bdschuym@pandora.be> wrote:
> =20
>
>>Can you do something similar with iptables rules to see if it's specifi=
c to=20
>>ebtables (which I doubt)?
>>
>>   =20
>>
OK. Done. I have tried to mimic ebtables rules as similar as possible.=20
Only difference is that iptables module mac has only --mac-source=20
option. Now I need to wait about 24 to 48 hours, to see if everything is=20
OK. I will tell you as soon I have more information.

>>>The only weird thing I noticed is when I initalise my bridge, is somet=
hing
>>>about that it can't get speed of some interfaces (guessing it is about
>>>e1000). I can't give you full error message at the moment, because tho=
se
>>>have been rotated by logrotate.
>>>     =20
>>>
>>I don't know what that is about...
>>
>>   =20
>>

Found it in kernel sources, it was giving error from line 62 of=20
net/bridge/br_if.c:

pr_info("bridge: can't decode speed from %s: %d\n",
                                dev->name, ecmd.speed);

Thanks!

--=20

Micha=B3 Margula, alchemyx@uznam.net.pl, http://alchemyx.uznam.net.pl/
"W =BFyciu pi=EAkne s=B1 tylko chwile" [Ryszard Riedel]
