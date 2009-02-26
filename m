From: Geert Uytterhoeven <Geert.Uytterhoeven@sonycom.com>
Subject: Re: [PATCH v2 net] gianfar : Do right check on num_txbdfree
Date: Thu, 26 Feb 2009 17:03:03 +0100 (CET)
Message-ID: <alpine.LRH.2.00.0902261701530.6201@vixen.sonytel.be>
References: <49A6595A.9000405@arvoo.nl> <20090226.020318.50178027.davem@davemloft.net> <49A66E2D.3060204@arvoo.nl>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, Linuxppc-dev@ozlabs.org,
	afleming@freescale.com, netdev@vger.kernel.org
To: Rini van Zetten <rini@arvoo.nl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vervifontaine.sonytel.be ([80.88.33.193]:56043 "EHLO
	vervifontaine.sonycom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754326AbZBZQDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 11:03:07 -0500
In-Reply-To: <49A66E2D.3060204@arvoo.nl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 26 Feb 2009, Rini van Zetten wrote:
> This patch fixes a wrong check on num_txbdfree. It could lead to num_=
txbdfree
> become nagative.
> Result was that the gianfar stops sending data.

A quick mental note for your next patch submission:

> Changes from first version :
> - removed a space between parens (David Millers comment)
> - full email address in signed off line

Changelogs since previous versions should be ...

> Signed-off-by: Rini van Zetten <rini@arvoo.nl>
> ---

=2E.. here, below the `---', as they're not supposed to be end up in th=
e final
commit message.

>  drivers/net/gianfar.c |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)

With kind regards,

Geert Uytterhoeven
Software Architect

Sony Techsoft Centre Europe
The Corporate Village =B7 Da Vincilaan 7-D1 =B7 B-1935 Zaventem =B7 Bel=
gium

Phone:    +32 (0)2 700 8453
=46ax:      +32 (0)2 700 8622
E-mail:   Geert.Uytterhoeven@sonycom.com
Internet: http://www.sony-europe.com/

A division of Sony Europe (Belgium) N.V.
VAT BE 0413.825.160 =B7 RPR Brussels
=46ortis =B7 BIC GEBABEBB =B7 IBAN BE41293037680010
