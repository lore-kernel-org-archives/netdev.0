From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [Patch v2] arp: fix a regression in arp_solicit()
Date: Mon, 24 Dec 2012 08:41:14 -0800
Message-ID: <1356367274.20133.9176.camel@edumazet-glaptop>
References: <1356312196-23185-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Sedat Dilek <sedat.dilek@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f53.google.com ([209.85.210.53]:37429 "EHLO
	mail-da0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753137Ab2LXQlS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Dec 2012 11:41:18 -0500
Received: by mail-da0-f53.google.com with SMTP id x6so3217620dac.40
        for <netdev@vger.kernel.org>; Mon, 24 Dec 2012 08:41:17 -0800 (PST)
In-Reply-To: <1356312196-23185-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-12-24 at 09:23 +0800, Cong Wang wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> Sedat reported the following commit caused a regression:
> 
> commit 9650388b5c56578fdccc79c57a8c82fb92b8e7f1
> Author: Eric Dumazet <edumazet@google.com>
> Date:   Fri Dec 21 07:32:10 2012 +0000
> 
>     ipv4: arp: fix a lockdep splat in arp_solicit
> 
> This is due to the 6th parameter of arp_send() needs to be NULL
> for the broadcast case, the above commit changed it to an all-zero
> array by mistake.
> 
> Reported-by: Sedat Dilek <sedat.dilek@gmail.com>
> Tested-by: Sedat Dilek <sedat.dilek@gmail.com>
> Cc: Sedat Dilek <sedat.dilek@gmail.com>
> Cc: Eric Dumazet <edumazet@google.com>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Julian Anastasov <ja@ssi.bg>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> ---

Oops, thanks for fixing this.

Acked-by: Eric Dumazet <edumazet@google.com>
