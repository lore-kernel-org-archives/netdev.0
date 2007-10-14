From: Al Boldi <a1426z@gawab.com>
Subject: Re: [2.6.20.21 review 12/35] TCP: Fix TCP handling of SACK in
Date: Sun, 14 Oct 2007 13:38:51 +0300
Message-ID: <200710141338.51927.a1426z@gawab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [212.12.190.105] ([212.12.190.105]:38273 "EHLO raad.intranet"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755367AbXJNKjC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2007 06:39:02 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:
> Willy Tarreau wrote:
> > I agree with this. The impression I got from the description of the=
 two
> > patches I merged was that the problems they fix were quite annoying=
=2E But
> > maybe I should take that with a grain of salt.
>
> No, it's not a grain of salt. I would say its utterly broken, out lou=
d.
> But many people are not that much into time-seq graphs (that I'm fami=
liar
> with), they are pleased when it seems to work well enough even though
> from my perspective, it is simply unacceptable in worst cases (not
> speaking of theoretical ones here, have seen very bad performance). N=
ot
> that it always is that bad, depends on phase of the opposite directio=
n
> what happens.
>
> Somebody asked me when those four patches were made about this, I put
> these there back then:
>
> http://www.cs.helsinki.fi/u/ijjarvin/bidir-showcase/
>
> They are generated from my old test archives and thus may have a bit
> differences in TCP variant, which may slightly differ from mainline
> here and there (my point was just to show how it breaks). Typical
> people wouldn't even notice those minor differences compared with the
> bidir brokeness which is very visible in all except in the fixed "ok"
> case. Please judge for yourself whether I overexaggrated or not... :-=
)

It would probably be helpful, if you could post a specific testcase and=
 a=20
combo-patch of your fixes.


Thanks!

--
Al

