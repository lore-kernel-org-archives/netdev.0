From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] SFQ planned changes
Date: Tue, 03 Jan 2012 13:50:36 +0100
Message-ID: <1325595036.2320.43.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <1325385056.4174.51.camel@denise.theartistscloset.com>
	 <21734335.uCtjXOcSpA@alaris>
	 <CAA93jw5NYChp+hKWjOWiw7SnGhNe+REofr2KM-85GnKNVpkw6w@mail.gmail.com>
	 <1325587235.2320.37.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <CAA93jw5T10PHD+YQQjy_r=LHKVbYeiWerwM0ou7HANGoenFRKw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Michal =?UTF-8?Q?Kube=C4=8Dek?= <mkubecek@suse.cz>,
	netdev@vger.kernel.org,
	"John A. Sullivan III" <jsullivan@opensourcedevel.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lpp01m010-f46.google.com ([209.85.215.46]:35414 "EHLO
	mail-lpp01m010-f46.google.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751574Ab2ACMul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 07:50:41 -0500
Received: by lahd3 with SMTP id d3so3699813lah.19
        for <netdev@vger.kernel.org>; Tue, 03 Jan 2012 04:50:39 -0800 (PST)
In-Reply-To: <CAA93jw5T10PHD+YQQjy_r=LHKVbYeiWerwM0ou7HANGoenFRKw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 03 janvier 2012 =C3=A0 13:07 +0100, Dave Taht a =C3=A9crit :

> From a 'doing science' perspective, I'd like it if it remained possib=
le
> to continue using and benchmarking SFQ as it was, and create
> this set of ideas as a new qdisc ('efq'?)
>=20
> As these changes seem to require changes to userspace tc, anyway,
> and (selfishly) my patching burden is great enough...
>=20
> Perhaps some additional benefit could be had by losing
> full backward API compatability with sfq, as well?

No, it's completely compatable with prior version.

An old tc command, or lack of new arguments will setup the SFQ qdisc
exactly as before.

I coded the thing and am doing stress tests before submission.
