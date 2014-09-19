From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH/RFC repost 5/8] datapath: Move last_action()
 helper to datapath.h
Date: Fri, 19 Sep 2014 15:06:38 +0100
Message-ID: <20140919140638.GC8257@casper.infradead.org>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-6-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1411005311-11752-6-git-send-email-simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
List-Unsubscribe: <http://openvswitch.org/mailman/options/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=unsubscribe>
List-Archive: <http://openvswitch.org/pipermail/dev>
List-Post: <mailto:dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Help: <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=help>
List-Subscribe: <http://openvswitch.org/mailman/listinfo/dev>,
 <mailto:dev-request-yBygre7rU0TnMu66kgdUjQ@public.gmane.org?subject=subscribe>
Errors-To: dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org
Sender: "dev" <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
List-Id: netdev.vger.kernel.org

On 09/18/14 at 10:55am, Simon Horman wrote:
> diff --git a/datapath/datapath.h b/datapath/datapath.h
> index c5d3c86..74a15e6 100644
> --- a/datapath/datapath.h
> +++ b/datapath/datapath.h
> @@ -209,4 +209,9 @@ do {								\
>  	if (net_ratelimit())					\
>  		pr_info("netlink: " fmt, ##__VA_ARGS__);	\
>  } while (0)
> +
> +static inline bool last_action(const struct nlattr *a, int rem)
> +{
> +	return a->nla_len == rem;
> +}
>  #endif /* datapath.h */

Can we rename & move this to <net/netlink.h> instead?
