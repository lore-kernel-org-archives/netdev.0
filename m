From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH 1/2 net] net/mlx4_core: Test interrupts fail if not all
 comp vectors called request_irq
Date: Thu, 8 Oct 2015 14:51:44 +0300
Message-ID: <CAJ3xEMi2-rLs=9b+6Lubog=ACqYUh1x+V+dViR_KYL0D1Q_vHg@mail.gmail.com>
References: <1444166829-17638-1-git-send-email-clsoto@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Or Gerlitz <ogerlitz@mellanox.com>, brking@linux.vnet.ibm.com
To: Carol L Soto <clsoto@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f173.google.com ([209.85.223.173]:33467 "EHLO
	mail-io0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756839AbbJHLvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Oct 2015 07:51:45 -0400
Received: by iofh134 with SMTP id h134so54869215iof.0
        for <netdev@vger.kernel.org>; Thu, 08 Oct 2015 04:51:44 -0700 (PDT)
In-Reply-To: <1444166829-17638-1-git-send-email-clsoto@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 7, 2015 at 12:27 AM,  <clsoto@linux.vnet.ibm.com> wrote:
> From: Carol L Soto <clsoto@linux.vnet.ibm.com>
>
> Test interrupts fails if not all completion vectors called
> request_irq. This case can happen if only mlx4_en loads and
> we have more completion vectors than rx rings.
>
> Fixes: c66fa19c405a ('net/mlx4: Add EQ pool')
> Acked-by: Matan Barak <matanb@mellanox.com>
> Signed-off-by: Carol L Soto <clsoto@linux.vnet.ibm.com>

Here too, I will submit this with other fixes we have, thanks a lot.
