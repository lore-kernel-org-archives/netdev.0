From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 0/8] [NET]: More uninlining & related
Date: Sat, 12 Jan 2008 03:16:18 -0800 (PST)
Message-ID: <20080112.031618.151656166.davem@davemloft.net>
References: <12001304691600-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: ilpo.jarvinen@helsinki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46648
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1761522AbYALLQT convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 06:16:19 -0500
In-Reply-To: <12001304691600-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: "Ilpo_J=E4rvinen" <ilpo.jarvinen@helsinki.fi>
Date: Sat, 12 Jan 2008 11:34:21 +0200

> First of all, I changed output encoding of git to utf-8, so I
> guess the encoding should not cause the same trouble for you.

I worked on a rebase of net-2.6.25 today and was able to
use emacs to fixup the encoding for all existing net-2.6.25
commits.

I've also put some things in place to avoid this problem in
the future.

Thanks.

> Here are couple of more to uninline things. Pretty
> straightforward except the EXPORT_SYMBOLs, I've no idea which
> is the right variant (feel free to fix them while applying :-)).
> Also pktgen uninlining is somewhat questionable because it's
> just a testing tool so feel free to drop it if it feels
> unnecessary (I could have asked first but it's just as easy to
> do it this way if not easier)...
>=20
> There were more dead static inlines found after inlines removed
> (gcc didn't report them otherwise) than in pktgen now included,
> but I'm not sure if I should send "by default" patches removing
> or #if 0'ing them?

Unless there is some pressing reason to keep the code around
it should be removed.

Anyways, I'll take a look.
