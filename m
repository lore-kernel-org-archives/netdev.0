From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] net: fec: Fix sparse warnings with different lock
 contexts for basic block
Date: Sat, 11 Oct 2014 18:22:40 -0300
Message-ID: <CAOMZO5AhnRFUiCNBQ8FwdvjqVM+1fHfa3DUoHbqKTDcdg7AfBA@mail.gmail.com>
References: <1412996429-2253-1-git-send-email-b38611@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	sparse@chrisli.org, Li Frank-B20596 <b20596@freescale.com>
To: Fugang Duan <b38611@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-la0-f53.google.com ([209.85.215.53]:38850 "EHLO
	mail-la0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750918AbaJKVWl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Oct 2014 17:22:41 -0400
Received: by mail-la0-f53.google.com with SMTP id gq15so5143222lab.12
        for <netdev@vger.kernel.org>; Sat, 11 Oct 2014 14:22:40 -0700 (PDT)
In-Reply-To: <1412996429-2253-1-git-send-email-b38611@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Fugang,

On Sat, Oct 11, 2014 at 12:00 AM, Fugang Duan <b38611@freescale.com> wrote:
> reproduce:
> make  ARCH=arm C=1 2>fec.txt drivers/net/ethernet/freescale/fec_main.o
> cat fec.txt
>
> sparse warnings:
> drivers/net/ethernet/freescale/fec_main.c:2916:12: warning: context imbalance
> in 'fec_set_features' - different lock contexts for basic block
>
> Christopher Li suggest to change as below:
>         if (need_lock) {
>                 lock();
>                 do_something_real();
>                 unlock();
>         } else {
>                 do_something_real();
>         }
>
> Reported-by: Fabio Estevam <festevam@gmail.com>
> Signed-off-by: Fugang Duan <B38611@freescale.com>
> Signed-off-by: Christopher Li <sparse@chrisli.org>

It looks like Suggested-by is a more appropriate tag for Christopher.
