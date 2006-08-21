From: Peter Bieringer <pb@bieringer.de>
Subject: (usagi-users 03687) Re: Bug in order of multiple IPv6 addresses per interface? Newest
 added one is preferred in difference to IPv4
Date: Mon, 21 Aug 2006 12:47:36 +0200
Message-ID: <44E98F48.70204@bieringer.de>
References: <44E94653.1040002@bieringer.de> <20060821.194253.07794662.yoshfuji@linux-ipv6.org>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
 <yoshfuji@linux-ipv6.org>,
        usagi-users@linux-ipv6.org
Return-path: <usagi-users-admin@linux-ipv6.org>
To: netdev@vger.kernel.org
In-Reply-To: <20060821.194253.07794662.yoshfuji@linux-ipv6.org>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E schrieb:
> Hello.
>=20
> In article <44E94653.1040002@bieringer.de> (at Mon, 21 Aug 2006 07:36:1=
9 +0200), Peter Bieringer <pb@bieringer.de> says:
>=20
>> In IPv6, the behavior is completly different:
>>
>> # ip -6 addr show dev eth0  |grep -w inet6 |grep -w global
>>     inet6 2001:db8:0:1::11/64 scope global
>>
>> # ip -6 addr add 2001:db8:0:1::253/64 dev eth0
>>
>> # ip -6 addr show dev eth0  |grep -w inet6 |grep -w global
>>     inet6 2001:db8:0:1::253/64 scope global   <- #2 !!!!
>>     inet6 2001:db8:0:1::11/64 scope global    <- #1
>>
>> So the last added on is now the first in list. Also, it gets no
>> "secondary" flag and "ip" doesn't even support this flag.
>=20
> IPv6 does not have secondary flag. We even reuse that for
> IPv6 temporary addresses.
>=20
>> And the worse thing is that the first one in list (=3D last added one)=
 is
>> now used as default for outgoing connections. Can be easily tested usi=
ng
>> "ping6".
> :
>> Is this a bug (I hope so) or a (undocumented?) feature?
>=20
> An implementation decision.

Thank you for this clarification.

> I do not favor changing this so far.

Hmm, would it be possible to implement a primary flag in the future?

BTW: Does anyone know about the behavior of *BSD for this issue?

	Peter
--=20
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                       mailto:pb@bieringer.de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
OpenBC                    http://www.openbc.com/hp/Peter_Bieringer/
Personal invitation to OpenBC  http://www.openbc.com/go/invita/3889
