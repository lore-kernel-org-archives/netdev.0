From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 07:42:30 -0500
Message-ID: <1200573750.4508.29.camel@localhost>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
	 <1200533980.4451.100.camel@localhost>
	 <20080117021743.GA5182@gondor.apana.org.au>  <478EED98.6080603@iki.fi>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:45274 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557AbYAQMmf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 07:42:35 -0500
Received: by py-out-1112.google.com with SMTP id u52so948832pyb.10
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 04:42:34 -0800 (PST)
In-Reply-To: <478EED98.6080603@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-17-01 at 07:54 +0200, Timo Ter=E4s wrote:

> You listen for the events. It is guaranteed that if the dumping code
> does return the entry to be deleted, the deletion notification will
> occur after that dump entry.

Ok, sounds reasonable - as long as there is a known order for
occurances, then there will be no ambiguity.
I am assuming that the same ordering will happen with
updates/modifications?
To go back to what i suggested earlier - is it possible to have this in
two stages? First pfkey with expected behavior being the same as curren=
t
netlink; then later the optimizations you are talking about.

Looking at the pfkey RFC one more time, heres a funny quote:
"
The dump message is used for debugging
purposes only and is not intended for production use.
"

One thing Dave mentioned thats extremely important is to ensure no ABI =
breakage.=20
Think of racoon 0.6 which knows nothing of this; it should continue to =
work.

Dave: One reason i paid attention to this is because it was on your TOD=
O
list from netconf 2005 ;-> It has just been sitting in the background
memory cells since.

cheers,
jamal

