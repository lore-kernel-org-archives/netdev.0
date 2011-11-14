From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [patch net-next V8] net: introduce ethernet teaming device
Date: Mon, 14 Nov 2011 19:17:52 +0100
Message-ID: <1321294672.2719.9.camel@edumazet-laptop>
References: <1321085808-6871-1-git-send-email-jpirko@redhat.com>
	 <20111113.160951.1905657808657009542.davem@davemloft.net>
	 <20111114173157.GE20605@gospo.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jpirko@redhat.com,
	netdev@vger.kernel.org, bhutchings@solarflare.com,
	shemminger@vyatta.com, fubar@us.ibm.com, tgraf@infradead.org,
	ebiederm@xmission.com, mirqus@gmail.com, kaber@trash.net,
	greearb@candelatech.com, jesse@nicira.com, fbl@redhat.com,
	benjamin.poirier@gmail.com, jzupka@redhat.com, ivecera@redhat.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:64586 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752616Ab1KNSR6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Nov 2011 13:17:58 -0500
Received: by bke11 with SMTP id 11so6172471bke.19
        for <netdev@vger.kernel.org>; Mon, 14 Nov 2011 10:17:57 -0800 (PST)
In-Reply-To: <20111114173157.GE20605@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 novembre 2011 =C3=A0 12:31 -0500, Andy Gospodarek a =C3=A9c=
rit :

> I'm a bit surprised by this.  Not only is this new function currently
> difficult to setup (it took me over an hour to go from a a fresh F16
> install to one that had all the necessary libraries and tools to even
> configure a team device for the first time), but I was able to cause =
an
> Oops with v8 in only a few minutes of testing.
>=20
> I have no problem with this functionality as an add-on and possibly
> future replacement to some of what currently exists with bonding, but=
 it
> seems like what is included in the initial support should should:
>=20
> 1. Not panic easily.
> 2. Have userspace bits in place to actually test all the proposed ker=
nel
> code.  (Jiri admits there is no way to verify the active-backup code)=
=2E
> 3. Have some known, published test results.
>=20
> I hope Jiri will reconsider having a separate team tree for the next =
few
> weeks or months until these issues are worked out.  I think the hard
> work will pay off and it is close to being ready; it just doesn't see=
m
> like it is right now.
>=20

Its marked EXPERIMENTAL, so probably some changes are expected before
production mode :)
