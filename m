From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Wed, 8 Apr 2009 23:06:58 +0200
Message-ID: <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com>
References: <1238701718.5669.26.camel@bender>
	 <20090407072647.GA11480@gondor.apana.org.au>
	 <1239108520.32737.28.camel@dogo.mojatatu.com>
	 <20090407130447.GA14329@gondor.apana.org.au>
	 <1239112067.32737.51.camel@dogo.mojatatu.com>
	 <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com>
	 <1239137800.21227.10.camel@dogo.mojatatu.com>
	 <20090407211130.GA5918@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: Evgeniy Polyakov <zbr@ioremap.net>, jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:60036 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756242AbZDHVHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 17:07:00 -0400
Received: by fxm2 with SMTP id 2so319168fxm.37
        for <netdev@vger.kernel.org>; Wed, 08 Apr 2009 14:06:58 -0700 (PDT)
In-Reply-To: <20090407211130.GA5918@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When you said "skb address", did you mean skb pointer value or
fragments data address?

If fragment data address, I can use first fragment page address to
deduce header address (in destructor)
As there is a constant offset between header address and data address.

However I'm afraid of issues once it is linearized.
Is there a sending path that will lose fragments info?

Best regards,
Johann
