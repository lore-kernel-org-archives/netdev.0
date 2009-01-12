From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] net: Remove redundant NAPI functions
Date: Mon, 12 Jan 2009 18:31:37 +0100
Message-ID: <m34p04bfd2.fsf@maximus.localdomain>
References: <1231446610.3893.17.camel@achroite>
	<20090112071317.GA4212@ff.dom.local>
	<1231769390.3075.2.camel@achroite> <1231771577.3075.5.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	David Miller <davem@davemloft.net>,
	Neil Horman <nhorman@tuxdriver.com>, shemminger@vyatta.com,
	netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:45213 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753522AbZALRbk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jan 2009 12:31:40 -0500
In-Reply-To: <1231771577.3075.5.camel@achroite> (Ben Hutchings's message of "Mon\, 12 Jan 2009 14\:46\:17 +0000")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings <bhutchings@solarflare.com> writes:

>> > > --- a/drivers/net/wan/ixp4xx_hss.c
>> > > +++ b/drivers/net/wan/ixp4xx_hss.c
>> [...]
>> =EF=BB=BF
>> What's the issue - does it conflict with another change to this file=
?
>
> Oh, now I see it - the device arguments hadn't already been removed.
> Yes, I'm afraid I failed to select this driver.

It's only possible on platforms based on IXP4xx (Intel's networking
ARM CPU).
--=20
Krzysztof Halasa
