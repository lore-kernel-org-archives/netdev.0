From: Johann Baudy <johann.baudy@gnu-log.net>
Subject: Re: [PATCH] TX_RING and packet mmap
Date: Sun, 12 Apr 2009 13:23:30 +0200
Message-ID: <7e0dd21a0904120423v4296898fl7ce82ec8c3e42d3a@mail.gmail.com>
References: <1238701718.5669.26.camel@bender>
	 <1239108520.32737.28.camel@dogo.mojatatu.com>
	 <20090407130447.GA14329@gondor.apana.org.au>
	 <1239112067.32737.51.camel@dogo.mojatatu.com>
	 <7e0dd21a0904070738jd8a2714wd840352699f1e9f1@mail.gmail.com>
	 <1239137800.21227.10.camel@dogo.mojatatu.com>
	 <20090407211130.GA5918@ioremap.net>
	 <7e0dd21a0904081406w31da460pe1c0c7153538f283@mail.gmail.com>
	 <7e0dd21a0904120327q537956abkf75a17d477cc2e61@mail.gmail.com>
	 <20090412103212.GA28397@ioremap.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f169.google.com ([209.85.218.169]:37633 "EHLO
	mail-bw0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753155AbZDLLXc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Apr 2009 07:23:32 -0400
Received: by bwz17 with SMTP id 17so1688087bwz.37
        for <netdev@vger.kernel.org>; Sun, 12 Apr 2009 04:23:30 -0700 (PDT)
In-Reply-To: <20090412103212.GA28397@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks Evgeniy,

> Page itself will live until destruction time, when skb is linearized
> page is freed, so your own destructor will find that given page is no
> longer used, and appropriate memory area can be overwritten.
Ok, so if my understanding is correct, fragment data is copied, frags
info (page, offset, size ...) of  skb_shinfo(skb) remain available and
skb->data_len is equal to 0 (to tag it as linear).
Then I can use address of skb_shinfo(n)->frags[0].page to derive my
header whatever sending path.
Is it correct?

Best regards,
Johann





-- 
Johann Baudy
johaahn@gmail.com
