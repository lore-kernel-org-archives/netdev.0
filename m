From: Frans Pop <elendil@planet.nl>
Subject: Re: Strange Application bug, race in MSG_PEEK complaints (was: Bug#513695: fetchmail: race in MSG_PEEK)
Date: Sat, 9 May 2009 20:14:34 +0200
Message-ID: <200905092014.35642.elendil@planet.nl>
References: <200902262310.12791.elendil@planet.nl> <20090506230240.GA10373@merlin.emma.line.org> <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthias Andree <matthias.andree@gmx.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?utf-8?q?J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml108.kpnxchange.com ([195.121.3.12]:51737 "EHLO
	CPSMTPM-EML108.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751974AbZEISOg convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 9 May 2009 14:14:36 -0400
In-Reply-To: <Pine.LNX.4.64.0905070931590.12068@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 07 May 2009, Ilpo J=C3=A4rvinen wrote:
> [RFC PATCH] tcp: fix MSG_PEEK race check
>
> Commit 518a09ef11 (tcp: Fix recvmsg MSG_PEEK influence of
> blocking behavior) lets the loop run longer than this check
> did previously expect, so we need to be more careful with
> this check and consider the work we have been doing.
>
> I'm a bit unsure if this improved check can still fail as
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0if (!sock_flag(sk, SO=
CK_URGINLINE)) {
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0++*seq;
> =C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=A0=C2=
=A0=C2=A0=C2=A0=C2=A0=C2=A0...
> does not increment copied.
>
> Compile tested.
>
> Signed-off-by: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>

I've been running with the patch for 2 days now and have not seen any m=
ore=20
MSG_PEEK errors, so as far as I'm concerned the patch does fix the issu=
e=20
(needed the time in order to be confident of that).

So:
Tested-by: Frans Pop <elendil@planet.nl>

Suggest to also add a CC for stable.

Cheers,
=46JP
