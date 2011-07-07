From: Wang Shaoyan <stufever@gmail.com>
Subject: Re: [PATCH] ATM: Fix wrong usage of INIT_WORK
Date: Thu, 7 Jul 2011 20:04:25 +0800
Message-ID: <CANxBZFo_2P+hrjNDmvU0wai2CA7Ry3LJ9vk+pZ4ML1RR12LKTQ@mail.gmail.com>
References: <1310039512-17579-1-git-send-email-wangshaoyan.pt@taobao.com>
	<20110707.045159.735589070219101177.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, wangshaoyan.pt@taobao.com,
	chas@cmf.nrl.navy.mil, linux-atm-general@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pv0-f174.google.com ([74.125.83.174]:51423 "EHLO
	mail-pv0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755732Ab1GGME0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2011 08:04:26 -0400
Received: by pvg12 with SMTP id 12so363406pvg.19
        for <netdev@vger.kernel.org>; Thu, 07 Jul 2011 05:04:25 -0700 (PDT)
In-Reply-To: <20110707.045159.735589070219101177.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I just don't know whether the marco FILL_RX_POOLS_IN_BH is useful?

2011/7/7 David Miller <davem@davemloft.net>:

>
> This just makes the driver a bigger CPP mess.
>
> Unconditionally provide the dev->bh member, and unconditionally pass
> it into the worker function.
>
>



-- 
Wang Shaoyan
