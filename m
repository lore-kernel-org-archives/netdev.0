From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] netpoll: cleanup sparse warnings
Date: Fri, 08 Feb 2013 08:44:43 -0800
Message-ID: <1360341883.28557.106.camel@edumazet-glaptop>
References: <1360248961-30721-1-git-send-email-nhorman@tuxdriver.com>
	 <1360252376.28557.52.camel@edumazet-glaptop>
	 <20130207183725.GE2379@shamino.rdu.redhat.com>
	 <1360293933.28557.92.camel@edumazet-glaptop>
	 <20130208154727.GB8771@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fengguang.wu@intel.com,
	David Miller <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-da0-f48.google.com ([209.85.210.48]:35292 "EHLO
	mail-da0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1946624Ab3BHQor (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Feb 2013 11:44:47 -0500
Received: by mail-da0-f48.google.com with SMTP id v40so1856575dad.21
        for <netdev@vger.kernel.org>; Fri, 08 Feb 2013 08:44:47 -0800 (PST)
In-Reply-To: <20130208154727.GB8771@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-08 at 10:47 -0500, Neil Horman wrote:

> Actually, I think all we need to do is take the rcu_read_lock and use
> rcu_dereference directly.  __netpoll_cleanup doesn't actually change the
> dev->npinfo pointer itself, thats handled by the caller, always under protection
> of the rtnl, so here we just need to ensure that no one changes npifo while
> we're using it

SGTM ;)
