From: William Allen Simpson <william.allen.simpson@gmail.com>
Subject: Re: [net-next-2.6 PATCH v5 3/5 RFC] TCPCT part1c: sysctl_tcp_cookie_size,
 socket option TCP_COOKIE_TRANSACTIONS, functions
Date: Tue, 10 Nov 2009 09:43:28 -0500
Message-ID: <4AF97C10.9020208@gmail.com>
References: <4AF83E2D.1050401@gmail.com> <4AF84458.9070000@gmail.com> <alpine.DEB.2.00.0911100706120.7059@melkinpaasi.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:38793 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756044AbZKJOn3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2009 09:43:29 -0500
Received: by ewy3 with SMTP id 3so86549ewy.37
        for <netdev@vger.kernel.org>; Tue, 10 Nov 2009 06:43:33 -0800 (PST)
In-Reply-To: <alpine.DEB.2.00.0911100706120.7059@melkinpaasi.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ilpo J=E4rvinen wrote:
> I guess most of the cookie stuff have nothing to do with the next,=20
> please make them separate:
>=20
>> Redefine two TCP header functions to accept TCP header pointer.
>> When subtracting, return signed int to allow error checking.
>=20
> Convert the users here, not in the fifth patch to avoid noise in the =
large=20
> fifth patch.
>=20
These comments are directly contrary to advice back on the 2nd or 3rd
round, where I'd both converted and removed the old functions here, bef=
ore
going on to use them everywhere.  I was told to *only* define the new o=
nes
here, use them in later patches as they applied, and then remove the ol=
d
functions in a final cleanup patch.

When I'm done (apparently very far in the distant future), there will b=
e
approximately 100 (maybe 150 or more) uses.


> And, I read more that fifth patch... seriously, please consider now t=
o=20
> apply _all_ the coding style changes that have been brought to your=20
> attention by multiple people (you should know them now but for some r=
eason=20
> again you choose to resent without complying -- I guess on purpose) i=
nto=20
> all upcoming patches you submit.
>=20
Pardon me, but I'm having difficulty finding a substantive comment.  Ar=
e
you attempting humor or sarcasm?  If so, it's not readily apparent.  It
seems more of an /ad hominem/ attack to me.

There were many painstaking hours of coding style changes, every single
one of them had to be individually examined side by side for correctnes=
s
after I ran a series of regexp over the patches -- in 148 blocks (I jus=
t
checked) of diff between the patch diffs, comprising eye-glazing trivia=
l
changes (although I used BBEdit's very nice GUI utility for the
side-by-side comparison).

If you don't like something else, please be specific (as others did
privately).  There may be places the regexp missed.

But more importantly, I'd prefer actual analysis.  Is there a better
Linux function to use for something (like RCU that Eric recommended)?

This is the *easy* patch series, based on code previously reviewed.  Th=
e
next series are much more conceptually difficult.  Maybe that's the
problem, this is too easy, and so the only things people find to commen=
t
about are trivia.

Please, more thoughtful code review, less interpersonal sniping.

TIA.

