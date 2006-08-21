From: Peter Bieringer <pb@bieringer.de>
Subject: (usagi-users 03690) Re: Bug in order of multiple IPv6 addresses per interface? Newest
 added one is preferred in difference to IPv4
Date: Mon, 21 Aug 2006 14:36:10 +0200
Message-ID: <44E9A8BA.8010904@bieringer.de>
References: <44E94653.1040002@bieringer.de>	 <20060821.194253.07794662.yoshfuji@linux-ipv6.org>	 <44E98F48.70204@bieringer.de> <y7vu046b8we.wl%jinmei@isl.rdc.toshiba.co.jp>
Reply-To: usagi-users@linux-ipv6.org
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: =?UTF-8?B?SklOTUVJIFRhdHV5YSAvIOelnuaYjumBlOWTiQ==?=
 <jinmei@isl.rdc.toshiba.co.jp>,
        usagi-users@linux-ipv6.org,
        =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
 <yoshfuji@linux-ipv6.org>
Return-path: <usagi-users-admin@linux-ipv6.org>
To: netdev@vger.kernel.org
In-Reply-To: <y7vu046b8we.wl%jinmei@isl.rdc.toshiba.co.jp>
List-Software: fml [fml 4.0.3 release (20011202/4.0.3)]
List-Post: <mailto:usagi-users@linux-ipv6.org>
List-Owner: <mailto:usagi-users-admin@linux-ipv6.org>
List-Help: <mailto:usagi-users-ctl@linux-ipv6.org?body=help>
List-Unsubscribe: <mailto:usagi-users-ctl@linux-ipv6.org?body=unsubscribe>
List-Id: netdev.vger.kernel.org

JINMEI Tatuya / =E7=A5=9E=E6=98=8E=E9=81=94=E5=93=89 schrieb:
>>>>>> On Mon, 21 Aug 2006 12:47:36 +0200,=20
>>>>>> Peter Bieringer <pb@bieringer.de> said:
>=20
>>> I do not favor changing this so far.
>=20
>> Hmm, would it be possible to implement a primary flag in the future?
>=20
>> BTW: Does anyone know about the behavior of *BSD for this issue?
>=20
> As far as I know, BSD variants don't have the notion of *explicit*
> 'first/primary' or 'secondary' address.  But if your main concern is
> to prefer particular addresses as the source address of outgoing
> packets, you'd be able to achieve the goal by configuring appropriate
> policy table entries (per RFC3484).

Hmm, can I do this on Linux, too for preferring a source address (out of
configured addresses from the *same subnet*)?

I only found:
http://people.redhat.com/drepper/linux-rfc3484.html
But this is more related to destination addresses.

Thank you very much.

	Peter
--=20
Dr. Peter Bieringer                     http://www.bieringer.de/pb/
GPG/PGP Key 0x958F422D                       mailto:pb@bieringer.de
Deep Space 6 Co-Founder and Core Member  http://www.deepspace6.net/
OpenBC                    http://www.openbc.com/hp/Peter_Bieringer/
Personal invitation to OpenBC  http://www.openbc.com/go/invita/3889
