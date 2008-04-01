From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Subject: Re: [PATCH 5 of 5] IPv6: temporary address: update the timer for
	tentative addresses
Date: Tue, 1 Apr 2008 23:53:25 +0200
Message-ID: <20080401215325.GN475@pirzuine>
References: <patchbomb.1206305168@pirzuine> <4765830d9f3848ef14e6.1206305173@pirzuine> <20080328.122558.13389103.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, pekkas@netcore.fi
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pilet.ens-lyon.fr ([140.77.167.16]:45714 "EHLO
	pilet.ens-lyon.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751571AbYDAVx3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Apr 2008 17:53:29 -0400
Content-Disposition: inline
In-Reply-To: <20080328.122558.13389103.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 28, 2008 at 12:25:58PM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <4765830d9f3848ef14e6.1206305173@pirzuine> (at Sun, 23 Mar=
 2008 21:46:13 +0100), Benoit Boissinot <benoit.boissinot@ens-lyon.org>=
 says:
>=20
> > IPv6: temporary address: update the timer for tentative addresses
> >=20
> > Even for tentative addresses, we should update the timer,
> > otherwise if the preferred lifetime is too short we will
> > miss the opportunity to regenerate the adress.
>=20
> Well, but it this ever happens, it implies that the lifetime
> is too short, doesn't it?
> We don't want such temporary address too much.

I do agree. In this case, short means less than ADDR_CHECK_FREQUENCY
(2 minutes), and it might be too aggressive.
In fact, I don't really know what are the consequences of running
with a very short regen for temporary addresses (let's say for example,
1 minutes preferred lifetime, and 5 minutes valid lifetime).

But it was really useful for me for testing it, and it fixes a bug
(anyway if you use too short lifetimes you'll hit the max addresses
limit really fast).

regards,

Benoit

ps: I'll resubmit the patches to which you already agreed soon.

--=20
:wq
