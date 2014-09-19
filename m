From: Nikolay Aleksandrov <nikolay@redhat.com>
Subject: Re: [PATCH net-next v4 1/2] bonding: display xmit_hash_policy for
 non-dynamic-tlb mode
Date: Fri, 19 Sep 2014 12:01:11 +0200
Message-ID: <541BFEE7.8030904@redhat.com>
References: <1411077194-20069-1-git-send-email-maheshb@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Maciej Zenczykowski <maze@google.com>
To: Mahesh Bandewar <maheshb@google.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Veaceslav Falico <vfalico@redhat.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30977 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753883AbaISKBY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Sep 2014 06:01:24 -0400
In-Reply-To: <1411077194-20069-1-git-send-email-maheshb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/18/2014 11:53 PM, Mahesh Bandewar wrote:
> It's a trivial fix to display xmit_hash_policy for this new TLB mode
> since it uses transmit-hash-poilicy as part of bonding-master info
> (/proc/net/bonding/<bonding-interface).
> 
> Signed-off-by: Mahesh Bandewar <maheshb@google.com>
> ---
> v1
>  Rebase
> v2
>  Added bond_mode_uses_xmit_hash() inline function
> v3
>  Rebase
> v4
>  Rebase
> 
>  drivers/net/bonding/bond_procfs.c | 3 +--
>  drivers/net/bonding/bonding.h     | 7 +++++++
>  2 files changed, 8 insertions(+), 2 deletions(-)
> 

Reviewed-by: Nikolay Aleksandrov <nikolay@redhat.com>
