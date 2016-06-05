From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1] ixgbe: replace rtnl_lock with rcu_read_lock
Date: Sun, 05 Jun 2016 04:14:16 -0700
Message-ID: <1465125256.2968.50.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1465118091-6233-1-git-send-email-zyjzyj2000@gmail.com>
	 <1465118091-6233-2-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:35506 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750785AbcFELOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jun 2016 07:14:18 -0400
Received: by mail-pa0-f46.google.com with SMTP id xk1so26922839pac.2
        for <netdev@vger.kernel.org>; Sun, 05 Jun 2016 04:14:18 -0700 (PDT)
In-Reply-To: <1465118091-6233-2-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-06-05 at 17:14 +0800, zyjzyj2000@gmail.com wrote:
> From: Zhu Yanjun <zyjzyj2000@gmail.com>
> 
> 
> Signed-off-by: Zhu Yanjun <zyjzyj2000@gmail.com>
> ---

You do not explain if this is a bug fix (targeting net tree) or simply
an optimization in the slow path (targeting net-next tree) ?

A changelog, even small, would be nice, even if the patch looks valid.
