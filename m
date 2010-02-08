From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC]: xfrm by mark
Date: Mon, 08 Feb 2010 09:58:30 -0500
Message-ID: <1265641110.3688.45.camel@bigi>
References: <1265567522.3688.27.camel@bigi>  <4B701204.6000106@trash.net>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>,
	Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f223.google.com ([209.85.218.223]:48356 "EHLO
	mail-bw0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752885Ab0BHO6h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Feb 2010 09:58:37 -0500
Received: by bwz23 with SMTP id 23so1189986bwz.1
        for <netdev@vger.kernel.org>; Mon, 08 Feb 2010 06:58:35 -0800 (PST)
In-Reply-To: <4B701204.6000106@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-02-08 at 14:30 +0100, Patrick McHardy wrote:

> If you simply add the mark to the lookup key, it will break
> existing setups already using marks. I'd suggest to also add
> a mask which is initialized to 0 when no mark attribute is
> present.

Good point - better safe than sorry (especially after the havoc
that ingress mark caused;->)

Would it be easier to just add a global sysctl with default being
"dont use marks"? It will be less memory use than a 32-bit mask per
mark..

cheers,
jamal

