From: =?ISO-8859-2?Q?Micha=B3_Margula?= <alchemyx@uznam.net.pl>
Subject: Re: Fw: [Bugme-new] [Bug 3746] New: Bridge causes machine lockups
Date: Sun, 21 Nov 2004 23:21:23 +0100
Message-ID: <41A114E3.5070705@uznam.net.pl>
References: <20041115122046.1413527e.akpm@osdl.org> <20041115124843.4c3dd72f.akpm@osdl.org> <419C8724.20006@uznam.net.pl> <200411211727.43320.bdschuym@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: Andrew Morton <akpm@osdl.org>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Bart De Schuymer <bdschuym@pandora.be>
In-Reply-To: <200411211727.43320.bdschuym@pandora.be>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Bart De Schuymer napisa=B3(a):

># cd /usr/src/linux-2.6.9/
># patch -p1 < patch
>When your system hangs again, the message "EBTABLES: BEFORE WRITE LOCK"
>should be in your syslog, and check that it is not followed by "EBTABLES=
:=20
>AFTER WRITE LOCK".
>
> =20
>
I have just applied that patch. Tomorrow I will reboot a new kernel. So=20
in about no more than two days, I should get some results.

>Is the bridge still forwarding packets while it hangs?
>
> =20
>
No. Box is completly frozen.

>Perhaps try to link all network traffic to one cpu before doing your ebt=
ables=20
>updates...
> =20
>
Could you give me more details about that? Should it be done before=20
updating ebtables, and after that reverting? And most important - how? :).


--=20
Micha=B3 Margula, alchemyx@uznam.net.pl, http://alchemyx.uznam.net.pl/
"W =BFyciu pi=EAkne s=B1 tylko chwile" [Ryszard Riedel]
