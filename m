From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] GRO scalability
Date: Sat, 06 Oct 2012 09:00:25 +0200
Message-ID: <1349506825.21172.241.camel@edumazet-glaptop>
References: <1348750130.5093.1227.camel@edumazet-glaptop>
	 <CAEP_g=-JAYHXM86AYNp7BhDV+eqfkKVgC+SJS1MVdo0K8fRLSQ@mail.gmail.com>
	 <1348769294.5093.1566.camel@edumazet-glaptop>
	 <1348769990.5093.1584.camel@edumazet-glaptop>
	 <CAEP_g=8B7xZPxye0Kuu-EVKpTDt1a3nsJKb61aaYaqOGsYGx8w@mail.gmail.com>
	 <1348841041.5093.2477.camel@edumazet-glaptop>
	 <CAEP_g=_nSb-ite51PM-E8SY53yOPiZs8N3gDrYNc0L4OU2Ht=A@mail.gmail.com>
	 <1349448747.21172.113.camel@edumazet-glaptop>
	 <20121006041155.GA27134@gondor.apana.org.au>
	 <1349500126.4883.4.camel@edumazet-laptop>
	 <20121006051407.GA27390@gondor.apana.org.au>
	 <1349504541.21172.183.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jesse Gross <jesse@nicira.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:38298 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750981Ab2JFHAa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 6 Oct 2012 03:00:30 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so1272152bkc.19
        for <netdev@vger.kernel.org>; Sat, 06 Oct 2012 00:00:28 -0700 (PDT)
In-Reply-To: <1349504541.21172.183.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2012-10-06 at 08:22 +0200, Eric Dumazet wrote:

> All drivers.
> 
> If the napi->poll() consumes all budget, we dont call napi_complete()

Probably nobody noticed, because TCP stack retransmits packets
eventually.

But this adds unexpected latencies.

I'll send a patch.
