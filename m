From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH v2 net-next 4/4] bonding: add proper __rcu annotation
 for current_arp_slave
Date: Tue, 15 Jul 2014 16:07:46 +0200
Message-ID: <53C535B2.4070306@redhat.com>
References: <1405432616-12414-1-git-send-email-edumazet@google.com> <1405432616-12414-5-git-send-email-edumazet@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Mahesh Bandewar <maheshb@google.com>
To: Eric Dumazet <edumazet@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34578 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750960AbaGOONX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 15 Jul 2014 10:13:23 -0400
In-Reply-To: <1405432616-12414-5-git-send-email-edumazet@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/15/2014 03:56 PM, Eric Dumazet wrote:
> Using __rcu annotation actually helps to spot all accesses to
> bond->current_arp_slave are correctly protected, with LOCKDEP support.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> ---
>  drivers/net/bonding/bond_main.c | 15 +++++++++------
>  drivers/net/bonding/bonding.h   |  2 +-
>  2 files changed, 10 insertions(+), 7 deletions(-)
> 

you're fast, thanks again :-)

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
