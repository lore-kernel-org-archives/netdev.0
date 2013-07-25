From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] veth: remove hardware checksum feature
Date: Thu, 25 Jul 2013 10:59:22 -0700
Message-ID: <1374775162.23313.22.camel@edumazet-glaptop>
References: <51F15E50.8080208@guap.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: "Vitaly E. Lavrov" <lve@guap.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f170.google.com ([209.85.220.170]:34680 "EHLO
	mail-vc0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756291Ab3GYR71 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jul 2013 13:59:27 -0400
Received: by mail-vc0-f170.google.com with SMTP id kw10so314100vcb.1
        for <netdev@vger.kernel.org>; Thu, 25 Jul 2013 10:59:24 -0700 (PDT)
In-Reply-To: <51F15E50.8080208@guap.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-07-25 at 21:20 +0400, Vitaly E. Lavrov wrote:
> The network device VETH can't support the feature NETIF_F_HW_CSUM.
> All locally generated packets have invalid checksum.
> Wrong commit http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/commit/?id=8093315a91340bca52549044975d8c7f673b28a1 ( 
> kernel 3.9.0 )
> 
> Workaround "ethtool -K vethX tx off"
> 
> Possible patch:

No idea of what the problem is.

Could you elaborate ?
