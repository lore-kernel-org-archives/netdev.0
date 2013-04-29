From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] gianfar: Fix reported sent bytes to BQL for
 Tx timestamping
Date: Mon, 29 Apr 2013 08:59:53 -0700
Message-ID: <1367251193.8964.326.camel@edumazet-glaptop>
References: <1367240268-32609-1-git-send-email-claudiu.manoil@freescale.com>
	  <1367243593.8964.306.camel@edumazet-glaptop>
	  <517E8354.1010503@freescale.com>
	  <1367249009.8964.312.camel@edumazet-glaptop>
	 <1367249315.8964.314.camel@edumazet-glaptop>
	 <517E9742.1010002@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f181.google.com ([209.85.192.181]:48424 "EHLO
	mail-pd0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756869Ab3D2P75 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 11:59:57 -0400
Received: by mail-pd0-f181.google.com with SMTP id q10so1338008pdj.26
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 08:59:56 -0700 (PDT)
In-Reply-To: <517E9742.1010002@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 18:52 +0300, Claudiu Manoil wrote:

> Interesting but non-trivial, I think. Is this allowed? I mean, doesn't
> the net stack overwrite this field?

Each layer is allowed to overwrite skb->cb[]

Some network drivers already do.
