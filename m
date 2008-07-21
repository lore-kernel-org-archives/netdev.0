From: "Alexander Beregalov" <a.beregalov@gmail.com>
Subject: Re: [GIT]: Networking
Date: Mon, 21 Jul 2008 13:48:18 +0400
Message-ID: <a4423d670807210248l1e2e6999ha462edc99002f964@mail.gmail.com>
References: <20080720.181440.122144107.davem@davemloft.net>
	 <20080721024056.GA4800@martell.zuzino.mipt.ru>
	 <20080720.194856.92564555.davem@davemloft.net>
	 <20080720.221106.201055562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: adobriyan@gmail.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, jeffrey.t.kirsher@intel.com
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.244]:19846 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754169AbYGUJsT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 05:48:19 -0400
Received: by an-out-0708.google.com with SMTP id d40so355342and.103
        for <netdev@vger.kernel.org>; Mon, 21 Jul 2008 02:48:19 -0700 (PDT)
In-Reply-To: <20080720.221106.201055562.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David!

There is another problem on sparc64 and happymeal ethernet card.

when tring to up interface:

kernel BUG at net/core/dev.c:1328

ip(1090): Kernel bad sw trap 5

__netif_schedule
happy_meal_set_multicast
__dev_set_rx_mode
dev_set_rx_mode
dev_open
dev_change_flags
do_setlink
rtnl_newlink
rtnetlink_rcv_msg
netlink_rcv_skb
