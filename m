From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH][net-next] gianfar: Fix reported sent bytes to BQL for
 Tx timestamping
Date: Mon, 29 Apr 2013 08:33:48 -0700
Message-ID: <1367249628.8964.316.camel@edumazet-glaptop>
References: <1367240268-32609-1-git-send-email-claudiu.manoil@freescale.com>
	 <1367243593.8964.306.camel@edumazet-glaptop>
	 <517E8354.1010503@freescale.com>
	 <1367249009.8964.312.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f177.google.com ([209.85.192.177]:60346 "EHLO
	mail-pd0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754511Ab3D2Pdv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Apr 2013 11:33:51 -0400
Received: by mail-pd0-f177.google.com with SMTP id p11so3703447pdj.36
        for <netdev@vger.kernel.org>; Mon, 29 Apr 2013 08:33:50 -0700 (PDT)
In-Reply-To: <1367249009.8964.312.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-04-29 at 08:23 -0700, Eric Dumazet wrote:

> > Does BQL really need to measure the bytes-on-wire or the bytes consumed
> > for buffering?
> 
> Yes.

I meant, bytes on wire.

If it was bytes consumed for buffering, we would use skb->truesize here.

Anyway, I am not sure your fix is enough if VLAN is used for example.
