From: Vijay Subramanian <subramanian.vijay@gmail.com>
Subject: Re: TCP and reordering
Date: Wed, 28 Nov 2012 10:52:39 -0800
Message-ID: <CAGK4HS-OQFGL6FY8jwXgh-pEjtjTo8oV6vTWg=GzFuJ66Lj15g@mail.gmail.com>
References: <CAAeewD8zsfb6QPFecvPab_oK3D3T7eG_M53MVvfJ2QrxUFxWSQ@mail.gmail.com>
	<50B4F2DA.8020206@hp.com>
	<CAAeewD9MtEx4uF6ezbBj7Ci5OzX8VK7p=WQ2TB3PfjmznA4X0w@mail.gmail.com>
	<20121127.210611.1127622873924794001.davem@davemloft.net>
	<20121128072611.GA26010@pob.ytti.fi>
	<CAGK4HS_GVZqoGVjd87N6skM-SBWyPtY-AhiR9FDcR8ty5x6Xbg@mail.gmail.com>
	<20121128085404.GB26010@pob.ytti.fi>
	<50B656CC.1040001@hp.com>
	<1354127585.14302.467.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Rick Jones <rick.jones2@hp.com>, Saku Ytti <saku@ytti.fi>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f46.google.com ([209.85.219.46]:46412 "EHLO
	mail-oa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755685Ab2K1Swk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Nov 2012 13:52:40 -0500
Received: by mail-oa0-f46.google.com with SMTP id h16so13713756oag.19
        for <netdev@vger.kernel.org>; Wed, 28 Nov 2012 10:52:40 -0800 (PST)
In-Reply-To: <1354127585.14302.467.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

>
> Note that this sysctl controls the initial value of the per socket
> reordering value. It _does_ increase automatically (assuming SACK is
> enabled of course)
>
>
>

I believe enabling SACK is not a requirement. Even with plain Reno,
reordering  is tracked in tp->reordering and the reordering event is
counted in LINUX_MIB_TCPRENOREORDER.
tcp_add_reno_sack()-->tcp_check_reno_reordering() is the code path.

Thanks,
Vijay
