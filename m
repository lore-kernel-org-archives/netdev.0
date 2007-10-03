From: Cedric Le Goater <legoater@free.fr>
Subject: Re: [PATCH net-2.6.24 0/3]: More TCP fixes
Date: Wed, 03 Oct 2007 13:58:12 +0200
Message-ID: <470383D4.9060307@free.fr>
References: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postfix2-g20.free.fr ([212.27.60.43]:45442 "EHLO
	postfix2-g20.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754452AbXJCMAR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Oct 2007 08:00:17 -0400
Received: from smtp6-g19.free.fr (smtp6-g19.free.fr [212.27.42.36])
	by postfix2-g20.free.fr (Postfix) with ESMTP id B42E11AD5113
	for <netdev@vger.kernel.org>; Wed,  3 Oct 2007 11:59:09 +0200 (CEST)
In-Reply-To: <1191409218982-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Ilpo !

Ilpo J=E4rvinen wrote:
> Hi Dave,
>=20
> Sacktag fastpath_cnt_hint seems to be very tricky to get right...
> I suppose this one fixes Cedric's case. I cannot say for sure   =20
> until there is something more definite indication of
> tcp_retrans_try_collapse origin than what the simple late WARN_ON
> gave for us. ...Especially since it's non-trivial to have skb
> hint "correctly" positioned in the write_queue while still ending
> up calling that function. However, considering how difficult it
> seems to be for Cedric to reproduce, it might well be this one.
>=20
> In addition, I noticed another reset which wasn't previously  =20
> converted to WARN_ON, so doing that now. Boot + simple xfer
> tested. Please apply to net-2.6.24.

I'm dropping the previous patches you sent me and switching to this pat=
chset.=20
right ?

Thanks,

C.
