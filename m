From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 2/2] netfilter: ipvs: Compress return logic
Date: Tue, 21 Mar 2017 18:49:59 +0300
Message-ID: <144902e5-76d4-f767-7b86-ba07d57cf5a7@cogentembedded.com>
References: <1490102599-27579-1-git-send-email-singhalsimran0@gmail.com>
 <1490102599-27579-3-git-send-email-singhalsimran0@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kadlec@blackhole.kfki.hu, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        gregkh@linuxfoundation.org, outreachy-kernel@googlegroups.com,
        wensong@linux-vs.org, horms@verge.net.au, ja@ssi.bg
To: simran singhal <singhalsimran0@gmail.com>, pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1490102599-27579-3-git-send-email-singhalsimran0@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

On 03/21/2017 04:23 PM, simran singhal wrote:

> Simplify function returns by merging assignment and return into
> one command line.

    You mean "one statement"?

> Signed-off-by: simran singhal <singhalsimran0@gmail.com>
> ---
>
>  --This is my contribution to the netfilter project of
>    Outreachy Round 14.
>
>  net/netfilter/ipvs/ip_vs_ftp.c | 5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>
> diff --git a/net/netfilter/ipvs/ip_vs_ftp.c b/net/netfilter/ipvs/ip_vs_ftp.c
> index d30c327..c93c937 100644
> --- a/net/netfilter/ipvs/ip_vs_ftp.c
> +++ b/net/netfilter/ipvs/ip_vs_ftp.c
> @@ -482,11 +482,8 @@ static struct pernet_operations ip_vs_ftp_ops = {
>
>  static int __init ip_vs_ftp_init(void)
>  {
> -	int rv;
> -
> -	rv = register_pernet_subsys(&ip_vs_ftp_ops);
>  	/* rcu_barrier() is called by netns on error */
> -	return rv;
> +	return register_pernet_subsys(&ip_vs_ftp_ops);
>  }
>
>  /*

MBR, Sergei
