From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: ipv6 issues after an DDoS for kernel 4.6.3
Date: Fri, 08 Jul 2016 17:40:10 +0200
Message-ID: <1467992410.30694.17.camel@edumazet-glaptop3.roam.corp.google.com>
References: <577FAFFD.2020306@gmx.de>
	 <1467987260.30694.2.camel@edumazet-glaptop3.roam.corp.google.com>
	 <577FBA04.8000706@gmx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Toralf =?ISO-8859-1?Q?F=F6rster?= <toralf.foerster@gmx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f66.google.com ([74.125.82.66]:36379 "EHLO
	mail-wm0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754911AbcGHPkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Jul 2016 11:40:14 -0400
Received: by mail-wm0-f66.google.com with SMTP id x83so7476504wma.3
        for <netdev@vger.kernel.org>; Fri, 08 Jul 2016 08:40:13 -0700 (PDT)
In-Reply-To: <577FBA04.8000706@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-07-08 at 16:34 +0200, Toralf F=C3=B6rster wrote:
> On 07/08/2016 04:14 PM, Eric Dumazet wrote:
> > Are you sure conntrack is needed at all ?
>=20
> Erm, I didn't mention conntrack - but yes, I do have in the firewall =
rules.
>=20
> It is my understanding that conntrack is best practise, right ?

It depends what you want to protect ?

linux TCP stack should work quite well without conntrack.

If you are aware of any known defect, we should fix TCP stack instead o=
f
working around by adding a very expensive framework.
