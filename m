From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2] net: remove delay at device dismantle
Date: Sat, 11 Aug 2012 07:54:47 +0200
Message-ID: <1344664487.5158.1.camel@edumazet-glaptop>
References: <1344590824.31104.1953.camel@edumazet-glaptop>
	 <20120810.034211.994338127277150687.davem@davemloft.net>
	 <1344596809.31104.2358.camel@edumazet-glaptop>
	 <1344609966.31104.2705.camel@edumazet-glaptop>
	 <1344613369.31104.2734.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Tom Herbert <therbert@google.com>,
	Mahesh Bandewar <maheshb@google.com>,
	"Eric W. Biederman" <ebiederm@xmission.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:44414 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751258Ab2HKFyx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Aug 2012 01:54:53 -0400
Received: by wgbdr13 with SMTP id dr13so2037415wgb.1
        for <netdev@vger.kernel.org>; Fri, 10 Aug 2012 22:54:51 -0700 (PDT)
In-Reply-To: <1344613369.31104.2734.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-08-10 at 17:42 +0200, Eric Dumazet wrote:
> From: Eric Dumazet <edumazet@google.com>
> 
> I noticed extra one second delay in device dismantle, tracked down to
> a call to dst_dev_event() while some call_rcu() are still in RCU queues.
> 
...
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Tom Herbert <therbert@google.com>
> Cc: Mahesh Bandewar <maheshb@google.com>
> Cc: "Eric W. Biederman" <ebiederm@xmission.com>
> ---
> v2: NETDEV_UNREGISTER_FINAL called outside of rtnl lock
>     as its more risky, base this patch on net-next

Also I am leaving for a one week vacation with no access to the
Internet, so better hold this patch until my return ;)

Thanks
