From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] netfilter: ipvs: remove the unused variable
Date: Thu, 19 Dec 2013 09:17:17 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1312190912090.1749@ja.home.ssi.bg>
References: <52B258A9.70002@huawei.com>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-1463811672-1559476761-1387437443=:1749"
Cc: wensong@linux-vs.org, horms@verge.net.au,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Wang Weidong <wangweidong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:35039 "EHLO ja.home.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752428Ab3LSHTi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Dec 2013 02:19:38 -0500
In-Reply-To: <52B258A9.70002@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---1463811672-1559476761-1387437443=:1749
Content-Type: TEXT/PLAIN; charset=UTF-8
Content-Transfer-Encoding: 8BIT


	Hello,

On Thu, 19 Dec 2013, Wang Weidong wrote:

> when I built the netfilter, I got that:
> net/netfilter/ipvs/ip_vs_sync.c: In function sync_thread_master’:
> net/netfilter/ipvs/ip_vs_sync.c:1640: warning: unused variable ‘ret’

	There is another patch that we plan to apply but
due to possible merge conflict it was delayed:

http://marc.info/?t=138426695600002&r=1&w=2
http://marc.info/?t=138426469400008&r=1&w=2

	May be it is time to apply it...

> Signed-off-by: Wang Weidong <wangweidong1@huawei.com>
> ---
>  net/netfilter/ipvs/ip_vs_sync.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/ipvs/ip_vs_sync.c b/net/netfilter/ipvs/ip_vs_sync.c
> index f63c238..d258125 100644
> --- a/net/netfilter/ipvs/ip_vs_sync.c
> +++ b/net/netfilter/ipvs/ip_vs_sync.c
> @@ -1637,7 +1637,7 @@ static int sync_thread_master(void *data)
>  			continue;
>  		}
>  		while (ip_vs_send_sync_msg(tinfo->sock, sb->mesg) < 0) {
> -			int ret = __wait_event_interruptible(*sk_sleep(sk),
> +			__wait_event_interruptible(*sk_sleep(sk),
>  						   sock_writeable(sk) ||
>  						   kthread_should_stop());
>  			if (unlikely(kthread_should_stop()))
> -- 
> 1.7.12

Regards

--
Julian Anastasov <ja@ssi.bg>
---1463811672-1559476761-1387437443=:1749--
