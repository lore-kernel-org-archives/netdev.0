From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v3] gre: fix a regression in ioctl
Date: Mon, 01 Jul 2013 23:36:01 -0700 (PDT)
Message-ID: <20130701.233601.1074563806368770464.davem@davemloft.net>
References: <CALnjE+qo33kqer_JQVwC+FDpmrSYpU2WkiYqeN6R11OWQkocug@mail.gmail.com>
	<1372478579-6548-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, pshelar@nicira.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47586 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750857Ab3GBGgC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 02:36:02 -0400
In-Reply-To: <1372478579-6548-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sat, 29 Jun 2013 12:02:59 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> When testing GRE tunnel, I got:
> 
>  # ip tunnel show
>  get tunnel gre0 failed: Invalid argument
>  get tunnel gre1 failed: Invalid argument
> 
> This is a regression introduced by commit c54419321455631079c7d
> ("GRE: Refactor GRE tunneling code.") because previously we
> only check the parameters for SIOCADDTUNNEL and SIOCCHGTUNNEL,
> after that commit, the check is moved for all commands.
> 
> So, just check for SIOCADDTUNNEL and SIOCCHGTUNNEL.
> 
> After this patch I got:
> 
>  # ip tunnel show
>  gre0: gre/ip  remote any  local any  ttl inherit  nopmtudisc
>  gre1: gre/ip  remote 192.168.122.101  local 192.168.122.45  ttl inherit 
> 
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Applied and queued up for -stable, thanks.
