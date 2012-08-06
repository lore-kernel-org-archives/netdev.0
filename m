From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/8] netpoll: use GFP_ATOMIC in slave_enable_netpoll()
 and __netpoll_setup()
Date: Mon, 06 Aug 2012 17:20:05 +0200
Message-ID: <1344266405.26674.30.camel@edumazet-glaptop>
References: <1344263012-4031-1-git-send-email-amwang@redhat.com>
	 <1344263012-4031-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46897 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932239Ab2HFPUK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Aug 2012 11:20:10 -0400
Received: by bkwj10 with SMTP id j10so1075865bkw.19
        for <netdev@vger.kernel.org>; Mon, 06 Aug 2012 08:20:08 -0700 (PDT)
In-Reply-To: <1344263012-4031-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-06 at 22:23 +0800, Cong Wang wrote:
> slave_enable_netpoll() and __netpoll_setup() may be called
> with read_lock() held, so should use GFP_ATOMIC to allocate
> memory. Eric suggested to pass gfp flags to __netpoll_setup().
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Reported-by: Dan Carpenter <dan.carpenter@oracle.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> ---

You based this on net-next, but didnt add the net-next suffix in your
[PATCH ...] description.

Signed-off-by: Eric Dumazet <edumazet@google.com>
