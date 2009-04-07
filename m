From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Tue, 7 Apr 2009 16:40:12 +0200
Message-ID: <7e0dd21a0904070740i74a35d91t311a70afc74e83e3@mail.gmail.com>
References: <1238701718.5669.26.camel@bender>
	 <20090407072647.GA11480@gondor.apana.org.au>
	 <1239108520.32737.28.camel@dogo.mojatatu.com>
	 <20090407130447.GA14329@gondor.apana.org.au>
	 <1239112067.32737.51.camel@dogo.mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:53272 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755641AbZDGOkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Apr 2009 10:40:14 -0400
Received: by bwz17 with SMTP id 17so2342075bwz.37
        for <netdev@vger.kernel.org>; Tue, 07 Apr 2009 07:40:12 -0700 (PDT)
In-Reply-To: <1239112067.32737.51.camel@dogo.mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,
Many thanks for your replies!

Indeed, I've tried to find a solution to store data in skb (valid
until destructor).

I've chosen this solution according to previous email on this subject:
http://lists.openwall.net/netdev/2008/11/11/93

I thought skb->mark was not used anymore at this level.
So I've used it to forward buffer index.

Do you think this solution is not acceptable?

Thanks,
Johann
