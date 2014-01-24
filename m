From: Emmanuel Thierry <ml@sekil.fr>
Subject: Re: IPV6 routing problem
Date: Fri, 24 Jan 2014 10:36:54 +0100
Message-ID: <CD36411A-7584-48B1-A406-E1584B3D32DD@sekil.fr>
References: <CAJzFV37rPo6trvCwWyErchen_MvTzqabSU+BE3JZjNXT5-5H7Q@mail.gmail.com> <20140122070759.GB28225@order.stressinduktion.org> <20140122071101.GC28225@order.stressinduktion.org> <CAJzFV34FhudmwOPY1q9SUtagb8rUuQanrAqt_+cOyETFsLcxqw@mail.gmail.com>
Mime-Version: 1.0 (Apple Message framework v1085)
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Sharat Masetty <sharat04@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host1.ip6-networks.net ([95.130.10.56]:38217 "EHLO
	host1.ip6-networks.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751053AbaAXJo2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jan 2014 04:44:28 -0500
In-Reply-To: <CAJzFV34FhudmwOPY1q9SUtagb8rUuQanrAqt_+cOyETFsLcxqw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Le 23 janv. 2014 =E0 08:15, Sharat Masetty a =E9crit :

> Unfortunately toggling this config setting CONFIG_IPV6_ROUTER_PREF di=
d
> not help, I see the same problem in both cases.
> The kernel version I am using is 3.10.0.
>=20
> Thanks for confirming that this is a non issue on 3.13 kernel version=
=2E
> Would you happen to know which patch would have potentially fixed thi=
s
> issue?

Your problem looks like the following one :=20
http://marc.info/?l=3Dlinux-netdev&m=3D137280268407054&w=3D2

Which has been fixed in 3.10.4, and 3.11+

> On Wed, Jan 22, 2014 at 12:11 AM, Hannes Frederic Sowa
> <hannes@stressinduktion.org> wrote:
>> On Wed, Jan 22, 2014 at 08:07:59AM +0100, Hannes Frederic Sowa wrote=
:
>>> Hi!
>>>=20
>>> On Tue, Jan 21, 2014 at 06:41:58PM -0700, Sharat Masetty wrote:
>>>> I have an IPV6 routing problem that has only surfaced on a 3.10
>>>> kernel version. This problem is not seen on 3.4 kernel. I will kee=
p
>>>> the problem statement as brief as possible.
>>>=20
>>> Could you do me a favor and test this on a recent 3.13 kernel? Than=
ks!
>>> Please also state the specific kernel version (I guess you use one)=
=2E
>>=20
>> +stable.
>>=20
>> A quick test worked for me. Maybe you could try with CONFIG_IPV6_ROU=
TER_PREF
>> enabled and one time with it disabled.
>>=20
>> We should make this knob a runtime setting soon...
>>=20
>> Thanks,
>>=20
>>  Hannes

Best regards.
Emmanuel Thierry
