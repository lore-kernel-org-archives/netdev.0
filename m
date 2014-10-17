From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: use hardware buffer pool to allocate skb
Date: Fri, 17 Oct 2014 12:51:55 -0700
Message-ID: <1413575515.27176.10.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1413343571-33231-1-git-send-email-Jiafei.Pan@freescale.com>
	 <20141015.002514.384962932982389732.davem@davemloft.net>
	 <c02005b9d8794d14bc2149f468ab571c@BY2PR03MB524.namprd03.prod.outlook.com>
	 <1413364533.12304.44.camel@edumazet-glaptop2.roam.corp.google.com>
	 <524626e093684abeba65839d26e94262@BLUPR03MB517.namprd03.prod.outlook.com>
	 <1413432912.28798.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <aeef795129504782ae1e9f91467d243e@BLUPR03MB517.namprd03.prod.outlook.com>
	 <543FE413.6030406@redhat.com>
	 <1413478657.28798.22.camel@edumazet-glaptop2.roam.corp.google.com>
	 <543FFC03.1060207@redhat.com>
	 <1413481529.28798.29.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54400C6C.7010405@redhat.com>
	 <063D6719AE5E284EB5DD2968C1650D6D1C9D895B@AcuExch.aculab.com>
	 <54412A59.7070508@redhat.com>
	 <1413564913.24709.7.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54415FEA.5000705@redhat.com>
	 <1413572539.25949.17.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54417044.5090602@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.h.duyck@redhat.com>,
	David Laight <David.Laight@ACULAB.COM>,
	"Jiafei.Pan@freescale.com" <Jiafei.Pan@freescale.com>,
	David Miller <davem@davemloft.net>,
	"jkosina@suse.cz" <jkosina@suse.cz>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"LeoLi@freescale.com" <LeoLi@freescale.com>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:46668 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753877AbaJQTv5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 17 Oct 2014 15:51:57 -0400
In-Reply-To: <54417044.5090602@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2014-10-17 at 12:38 -0700, Alexander Duyck wrote:

> That's not what I am saying, but there is a trade-off we always have to
> take into account.  Cutting memory overhead will likely have an impact
> on performance.  I would like to make the best informed trade-off in
> that regard rather than just assuming worst case always for the driver.

It seems you misunderstood me. You believe I suggested doing another
allocation strategy in the drivers.

This was not the case.

This allocation strategy is wonderful. I repeat : This is wonderful.

We only have to make sure we do not fool memory management layers, when
they do not understand where the memory is.

Apparently you think it is hard, while it really is not.
