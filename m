From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: make skb_set_owner_w() more robust
Date: Sun, 01 Nov 2015 15:27:12 -0800
Message-ID: <1446420432.6254.103.camel@edumazet-glaptop2.roam.corp.google.com>
References: <201511020754.lUc7VUJE%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, David Miller <davem@davemloft.net>,
	haiyangz@microsoft.com, edumazet@google.com,
	netdev@vger.kernel.org, kys@microsoft.com
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f44.google.com ([209.85.220.44]:33948 "EHLO
	mail-pa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753087AbbKAX1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 18:27:14 -0500
Received: by padec8 with SMTP id ec8so18991514pad.1
        for <netdev@vger.kernel.org>; Sun, 01 Nov 2015 15:27:14 -0800 (PST)
In-Reply-To: <201511020754.lUc7VUJE%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-02 at 07:18 +0800, kbuild test robot wrote:
> Hi Eric,
> 
> [auto build test ERROR on net-next/master -- if it's inappropriate base, please suggest rules for selecting the more suitable base]
> 
> url:    https://github.com/0day-ci/linux/commits/Eric-Dumazet/net-make-skb_set_owner_w-more-robust/20151102-070107
> config: x86_64-randconfig-x019-201544 (attached as .config)
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64 
> 
> All errors (new ones prefixed by >>):
> 
>    net/core/sock.c: In function 'skb_set_owner_w':
> >> net/core/sock.c:1664:21: error: 'sock_edemux' undeclared (first use in this function)
>       skb->destructor = sock_edemux;
>                         ^
>    net/core/sock.c:1664:21: note: each undeclared identifier is reported only once for each function it appears in

Yes, I forgot sock_edemux() was guarded by CONFIG_INET.

Kind of silly options really...

I will send a V2.
