From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH][next] sctp: make array sctp_sched_ops static
Date: Wed, 11 Oct 2017 07:39:07 -0400
Message-ID: <20171011113906.GA5546@hmswarspite.think-freely.org>
References: <20171011101757.18825-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vlad Yasevich <vyasevich@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20171011101757.18825-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 11, 2017 at 11:17:57AM +0100, Colin King wrote:
> From: Colin Ian King <colin.king@canonical.com>
> 
> The array sctp_sched_ops  is local to the source and
> does not need to be in global scope, so make it static.
> 
> Cleans up sparse warning:
> symbol 'sctp_sched_ops' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>
> ---
>  net/sctp/stream_sched.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/sctp/stream_sched.c b/net/sctp/stream_sched.c
> index 03513a9fa110..0b83ec51e43b 100644
> --- a/net/sctp/stream_sched.c
> +++ b/net/sctp/stream_sched.c
> @@ -124,7 +124,7 @@ static struct sctp_sched_ops sctp_sched_fcfs = {
>  extern struct sctp_sched_ops sctp_sched_prio;
>  extern struct sctp_sched_ops sctp_sched_rr;
>  
> -struct sctp_sched_ops *sctp_sched_ops[] = {
> +static struct sctp_sched_ops *sctp_sched_ops[] = {
>  	&sctp_sched_fcfs,
>  	&sctp_sched_prio,
>  	&sctp_sched_rr,
> -- 
> 2.14.1
> 
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
