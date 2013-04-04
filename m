From: Chen Gang <gang.chen@asianux.com>
Subject: Re: [Suggestion] ISDN: isdnloop: C grammar issue, '}' miss match
 'if' and 'switch' statement.
Date: Thu, 04 Apr 2013 16:30:01 +0800
Message-ID: <515D3A09.7040202@asianux.com>
References: <515C303B.1040304@asianux.com> <20130403140823.GB3401@unicorn.suse.cz> <1364999477.13853.21.camel@edumazet-glaptop> <CA+55aFw+Efs+um15_V6t-9rXd-U1VJS9p+_6E-m5jr87h-BPVg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Michal Kubecek <mkubecek@suse.cz>,
	Wu Fengguang <fengguang.wu@intel.com>,
	Karsten Keil <isdn@linux-pingi.de>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Joe Perches <joe@perches.com>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:33223 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933579Ab3DDIah (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Apr 2013 04:30:37 -0400
In-Reply-To: <CA+55aFw+Efs+um15_V6t-9rXd-U1VJS9p+_6E-m5jr87h-BPVg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


  firstly, thank you very much for your details reply and your patch.

On 2013=C4=EA04=D4=C203=C8=D5 23:30, Linus Torvalds wrote:
> On Wed, Apr 3, 2013 at 7:31 AM, Eric Dumazet <eric.dumazet@gmail.com>=
 wrote:
>>
>> And what is the problem exactly ?
>=20
> The indentation does look completely broken.
>=20
> It should still *work*, because case-statements don't actually care
> about nesting (you can use a case statement to jump into other contro=
l
> statements, the traditional example is the so-called "duff's device")=
,
> but I agree with Chen Gang that it looks wrong.
>=20

  ok, thanks.


> I'm attaching a patch that would appear to fix the nesting, but I
> haven't actually tested it. Also, regardless of that patch, the code
> looks like complete and utter crap, because it sets the "i" variable
> in many of the case statements, and then doesn't actually *use* it.
> Finally, almost all of the case statements test for something like
>=20
>     if (c->arg < ISDNLOOP_BCH) {
>=20
> but if "c->arg" is out of range, it will then just break out of the
> switch statement and return 0, even though it looks like it should be
> an error.
>=20

  really, it is.

> Of course, nobody sane actually cares about ISDN any more, so I think
> this is all pretty academic. I think even Germany (where ISDN *used*
> to be very common due to telephone monopolies and odd rules) no longe=
r
> uses it. I can't imagine that anybody else does either.
>=20

  can we delete it ?

  it will not provide contributes any more, but can waste other members=
'
time resources.

> But if somebody does care, and can validate my patch (if not by
> actually using it, then by at least looking at it more), feel free to
> take it and take my sign-off.
>=20
>      Linus
>=20

  for me, I suggest:
    if we can not delete it, we'd better to apply Linus' patch.

--=20
Chen Gang

Asianux Corporation
