From: jamal <hadi@cyberus.ca>
Subject: Re: [RFC][PATCH] Fixing SA/SP dumps on netlink/af_key
Date: Thu, 17 Jan 2008 08:18:24 -0500
Message-ID: <1200575904.4508.60.camel@localhost>
References: <E1JFHDM-00010A-00@gondolin.me.apana.org.au>
	 <1200533980.4451.100.camel@localhost>
	 <20080117021743.GA5182@gondor.apana.org.au> <478EED98.6080603@iki.fi>
	 <1200573750.4508.29.camel@localhost>
	 <20080117125016.GA9820@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.179]:36128 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750952AbYAQNSa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 08:18:30 -0500
Received: by py-out-1112.google.com with SMTP id u52so960519pyb.10
        for <netdev@vger.kernel.org>; Thu, 17 Jan 2008 05:18:29 -0800 (PST)
In-Reply-To: <20080117125016.GA9820@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2008-17-01 at 23:50 +1100, Herbert Xu wrote:

> In fact it goes much further:
> 
>    Support for the dump message MAY be discontinued in future versions
>    of PF_KEY.  Key management applications MUST NOT depend on this
>    message for basic operation.

No doubt PF_KEY being an RFC has caused a lot of damage. 
Once something is deployed, unfortunately, it grows a foot and sometimes
a head[1]. 
Note: it's a big dilema in my mind as well and i agree in principle with
both Dave and you (we really should not be helping pfkey grow another
ear on the forehead); the only way i am convincing myself otherwise is
to note that Racoon/ipsec-tools is out there, shipped as default ipsec
user management tools by most if not all linux distros. If we really
want to stop the beast lets cut out the umbilicall code - just take out
pfkey altogether from Linux ;->


cheers,
jamal

[1] Whatever fix/approach Timo has will eventually show up in the BSDs
and solaris for example 

