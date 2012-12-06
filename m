From: chas williams - CONTRACTOR <chas@cmf.nrl.navy.mil>
Subject: Re: [Suggestion] net/atm : for sprintf, need check the total write
 length whether larger than a page.
Date: Thu, 6 Dec 2012 09:08:55 -0500
Message-ID: <20121206090855.5f166746@thirdoffive.cmf.nrl.navy.mil>
References: <201212050357.qB53vHvT022706@thirdoffive.cmf.nrl.navy.mil>
	<50BED40D.9080100@asianux.com>
	<50BEDE4E.8010408@asianux.com>
	<50BEE2BE.2030704@asianux.com>
	<20121205095503.6d1c083d@thirdoffive.cmf.nrl.navy.mil>
	<50BFF19E.1040405@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Chen Gang <gang.chen@asianux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hedwig.cmf.nrl.navy.mil ([134.207.12.162]:45850 "EHLO
	hedwig.cmf.nrl.navy.mil" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932088Ab2LFOJG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Dec 2012 09:09:06 -0500
In-Reply-To: <50BFF19E.1040405@asianux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 06 Dec 2012 09:15:10 +0800
Chen Gang <gang.chen@asianux.com> wrote:

> =D3=DA 2012=C4=EA12=D4=C205=C8=D5 22:55, chas williams - CONTRACTOR =D0=
=B4=B5=C0:

> > did you mean '\0' instead of '\n'?  scnprintf() considers the trail=
ing
> > '\0' when formatting.
>=20
>   no, originally, the end is "\n\0".
>=20
>   I prefer we still compatible "\n" when the contents are very large.
>   if count already =3D=3D (PAGE_SIZE - 1), we have no chance to appen=
d "\n" to the end.
>=20
> -		pos +=3D sprintf(pos, "\n");
> +		count +=3D scnprintf(buf + count, PAGE_SIZE - count, "\n");

i would make the code a bit messy to do this for not much gain.  again,
it isnt likely you would run into this in a normal situation.
