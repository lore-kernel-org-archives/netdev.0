From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 8/8] [PKTGEN]: uninline getCurUs
Date: Sat, 12 Jan 2008 20:22:24 -0800 (PST)
Message-ID: <20080112.202224.135071859.davem@davemloft.net>
References: <1200130817467-git-send-email-ilpo.jarvinen@helsinki.fi>
	<12001308174189-git-send-email-ilpo.jarvinen@helsinki.fi>
	<20080112121740.GA4555@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54716
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752042AbYAMEW0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Jan 2008 23:22:26 -0500
In-Reply-To: <20080112121740.GA4555@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 12 Jan 2008 23:17:40 +1100

> Your emails are now using UTF-8 encoding but it's still declaring
> ISO-8859-1 as the charset.  So you probably want to fix that up or
> your name may show up as J=C3=A4vinen on the reader's screen.

Yes, for people using the GIT email patch applying tools, it might do
that.  However I believe there are options to git-am and friends to
force it to put things into UTF-8.

I ran into some problems with encoding because I apply stuff by hand
using scripts I wrote.

But those problem won't happen any more for me.

I'm now saving the commit message and patch into files explicitly in
emacs, and verifying the coding (with "C-h C RET") and if it's wrong I
fix it before saving with "C-x RET f mule-utf-8"

Then I feed those into my patch applying scripts.
