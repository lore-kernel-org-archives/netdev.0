From: Frans Pop <elendil@planet.nl>
Subject: Re: Strange Application bug, race in MSG_PEEK complaints (was: Bug#513695: fetchmail: race in MSG_PEEK)
Date: Thu, 7 May 2009 22:43:18 +0200
Message-ID: <200905072243.19546.elendil@planet.nl>
References: <200902262310.12791.elendil@planet.nl> <200905071916.57903.elendil@planet.nl> <Pine.LNX.4.64.0905072139001.15149@wrl-59.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matthias Andree <matthias.andree@gmx.de>,
	David Miller <davem@davemloft.net>,
	Netdev <netdev@vger.kernel.org>
To: "Ilpo =?utf-8?q?J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Cpsmtpm-eml106.kpnxchange.com ([195.121.3.10]:51878 "EHLO
	CPSMTPM-EML106.kpnxchange.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751060AbZEGU6d convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 May 2009 16:58:33 -0400
In-Reply-To: <Pine.LNX.4.64.0905072139001.15149@wrl-59.cs.helsinki.fi>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 07 May 2009, Ilpo J=C3=A4rvinen wrote:
> > Can you please elaborate why you think that? It may be horribly
> > broken (I've never claimed to be a C coder, and probably never will=
),
> > but it also really is the patch that generates the printks...
>
> ...This was mainly meant to be a joke... :-)
>
> The parenthesis won't match how a printk with string and 4 args shoul=
d
> be called, so with this version you have in the mail peek_seq and
> tp->copied_seq are not put into stack or you were just super lucky.

Ah, yes. You're absolutely right. Duh.
gcc does warn about it, but I must have missed that.
