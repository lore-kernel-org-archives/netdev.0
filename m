From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Sun, 12 Apr 2009 12:27:04 +0200
Message-ID: <7e0dd21a0904120327q537956abkf75a17d477cc2e61@mail.gmail.com>
References: <1238701718.5669.26.camel@bender>
	 <20090407072647.GA11480@gondor.apana.org.au>
	 <1239108520.32737.28.camel@dogo.mojatatu.com>
	 <20090407130447.GA14329@gondor.apana.org.au>
	 <1239112067.32737.51.camel@dogo.mojatatu.com>
	 <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com>
	 <1239137800.21227.10.camel@dogo.mojatatu.com>
	 <20090407211130.GA5918@ioremap.net>
	 <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:33915 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755429AbZDLK1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2009 06:27:07 -0400
Received: by fxm2 with SMTP id 2so1661500fxm.37
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2009 03:27:04 -0700 (PDT)
In-Reply-To: <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Evgeniy,

> It should, I actually do not see any sending path which does not invoke
> original skb destructor with the new data. It does not change the fact
> though, that effectively any other skb field can be modified during skb
> lifecycle no matter at which level it was allocated.
> Having a data pointer as an index could work though, especially it looks
> promising for fragments placed in own pages.

Do you mean that skb_shinfo(skb)->frags[i].page will be valid until
destructor? even if linearized, cloned ....?

Thanks in advance for your help,
Johann
