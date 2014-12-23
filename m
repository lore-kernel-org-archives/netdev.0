From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [PATCH 1/1 net-next] netfilter: remove unnecessary sizeof(char)
Date: Tue, 23 Dec 2014 14:33:38 +0100
Message-ID: <20141223133338.GA15456@salvia>
References: <1419273375-24312-1-git-send-email-fabf@skynet.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, davem@davemloft.net, joe@perches.com,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	netdev@vger.kernel.org
To: Fabian Frederick <fabf@skynet.be>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:34643 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755249AbaLWNbL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Dec 2014 08:31:11 -0500
Content-Disposition: inline
In-Reply-To: <1419273375-24312-1-git-send-email-fabf@skynet.be>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 22, 2014 at 07:36:15PM +0100, Fabian Frederick wrote:
> sizeof(char) is always 1.

Applied, thanks.

Made a small change on it:

> Suggested-by: Joe Perches <joe@perches.com>
> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> ---
>  net/netfilter/nf_log.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/netfilter/nf_log.c b/net/netfilter/nf_log.c
> index 43c926c..1191f66 100644
> --- a/net/netfilter/nf_log.c
> +++ b/net/netfilter/nf_log.c
> @@ -426,7 +426,7 @@ static int netfilter_log_sysctl_init(struct net *net)
>  				nf_log_sysctl_fnames[i];
>  			nf_log_sysctl_table[i].data = NULL;
>  			nf_log_sysctl_table[i].maxlen =
> -				NFLOGGER_NAME_LEN * sizeof(char);
> +				NFLOGGER_NAME_LEN;

this now fits in one line (80-chars).

>  			nf_log_sysctl_table[i].mode = 0644;
>  			nf_log_sysctl_table[i].proc_handler =
>  				nf_log_proc_dostring;
> -- 
> 1.9.1
> 
