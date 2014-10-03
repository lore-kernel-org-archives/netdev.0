From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH net-next 1/1] net: fec: fix build error at m68k platform
Date: Fri, 3 Oct 2014 17:07:29 -0300
Message-ID: <CAOMZO5B=cgVT1gr5VJ78x_Aj5ssvrsTOq4t0DrrLK4kz7vNMjQ@mail.gmail.com>
References: <1412362831-59318-1-git-send-email-Frank.Li@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	=?UTF-8?B?5p2O5pm6?= <lznuaa@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Duan Fugang-B38611 <b38611@freescale.com>
To: Frank Li <Frank.Li@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f169.google.com ([209.85.217.169]:35105 "EHLO
	mail-lb0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750837AbaJCUHb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Oct 2014 16:07:31 -0400
Received: by mail-lb0-f169.google.com with SMTP id 10so1629955lbg.28
        for <netdev@vger.kernel.org>; Fri, 03 Oct 2014 13:07:29 -0700 (PDT)
In-Reply-To: <1412362831-59318-1-git-send-email-Frank.Li@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 3, 2014 at 4:00 PM, Frank Li <Frank.Li@freescale.com> wrote:
> reproduce:
>   wget https://git.kernel.org/cgit/linux/kernel/git/wfg/lkp-tests.git/plain/sbin/make.cross -O ~/bin/make.cross
>   chmod +x ~/bin/make.cross
>   git checkout 1b7bde6d659d30f171259cc2dfba8e5dab34e735
>   # save the attached .config to linux build tree

There is no attached config ;-)

>   make.cross ARCH=m68k
>
> All error/warnings:
>
>    drivers/net/ethernet/freescale/fec_main.c: In function 'fec_enet_rx_queue':
>>> drivers/net/ethernet/freescale/fec_main.c:1470:3: error: implicit declaration of function 'prefetch' [-Werror=implicit-function-declaration]
>       prefetch(skb->data - NET_IP_ALIGN);
>       ^
>    cc1: some warnings being treated as errors
>
> missed included prefetch.h
>
> Signed-off-by: Frank Li <Frank.Li@freescale.com>

It seems you missed the Reported-by: kbuild test robot
<fengguang.wu@intel.com> tag.
