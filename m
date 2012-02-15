From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 3.0: unexpected route cache entry for wrong segment?
Date: Wed, 15 Feb 2012 14:03:33 +0100
Message-ID: <1329311013.2437.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F33FC0E.4020701@msgid.tls.msk.ru>
	  <1328809519.6099.7.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	  <4F341283.1020904@msgid.tls.msk.ru> <4F3BA0BD.9010501@msgid.tls.msk.ru>
	 <1329310007.2437.16.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F3BABD3.5070404@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Michael Tokarev <mjt@tls.msk.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:62523 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754591Ab2BONDh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Feb 2012 08:03:37 -0500
Received: by werb13 with SMTP id b13so600211wer.19
        for <netdev@vger.kernel.org>; Wed, 15 Feb 2012 05:03:35 -0800 (PST)
In-Reply-To: <4F3BABD3.5070404@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 15 f=C3=A9vrier 2012 =C3=A0 16:57 +0400, Michael Tokarev a =
=C3=A9crit :

> 3.0.21 included "net: fix NULL dereferences in check_peer_redir()" pa=
tch
> (which is somewhat large(ish) - I wonder why it has been rolled into
> single patch while in reality it consists of 7 commits; and I wonder
> why the final result is different from current version in check_peer_=
redir()
> routine, which I mentioned in my other email in this thread), but tha=
t
> one does not seem to address this very issue - from a quick view anyw=
ay.

That was the tricky part handled by David.

We couldnt apply all needed commits without bringing too many things
from recent kernels to 3.0  (out of stable scope)

If you believe a fix is needed, just shout :)
