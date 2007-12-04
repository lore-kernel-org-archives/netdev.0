From: Joe Perches <joe@perches.com>
Subject: Re: [NETLINK]: af_netlink.c checkpatch cleanups
Date: Tue, 04 Dec 2007 09:21:03 -0800
Message-ID: <1196788863.4898.13.camel@localhost>
References: <47550AA8.3030608@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from DSL022.labridge.com ([206.117.136.22]:4674 "EHLO perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751004AbXLDRYT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 4 Dec 2007 12:24:19 -0500
In-Reply-To: <47550AA8.3030608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2007-12-04 at 09:07 +0100, Patrick McHardy wrote:
> [NETLINK]: af_netlink.c checkpatch cleanups
> -static __inline__ void
> +static inline void
>  netlink_lock_table(void)
>  {
>  	/* read_lock() synchronizes us to netlink_table_grab */
> @@ -208,14 +208,15 @@ netlink_lock_table(void)
>  	read_unlock(&nl_table_lock);
>  }
>  
> -static __inline__ void
> +static inline void
>  netlink_unlock_table(void)
>  {
>  	if (atomic_dec_and_test(&nl_table_users))
>  		wake_up(&nl_table_wait);
>  }
>  
> -static __inline__ struct sock *netlink_lookup(struct net *net, int protocol, u32 pid)
> +static inline struct sock *netlink_lookup(struct net *net, int protocol,
> +					  u32 pid)

netlink_lock_table and netlink_unlock_table are the only
function definitions in this patch that have newlines between
function type and function name.

Perhaps checkpatch should warn on newlines between function type
and function names.


