From: Thomas Graf <tgraf-G/eBtMaohhA@public.gmane.org>
Subject: Re: [PATCH/RFC repost 3/8] odp-util: formatting of
 datapath select group action
Date: Fri, 19 Sep 2014 14:44:49 +0100
Message-ID: <20140919134449.GA8257@casper.infradead.org>
References: <1411005311-11752-1-git-send-email-simon.horman@netronome.com>
 <1411005311-11752-4-git-send-email-simon.horman@netronome.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dev-yBygre7rU0TnMu66kgdUjQ@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
Return-path: <dev-bounces-yBygre7rU0TnMu66kgdUjQ@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1411005311-11752-4-git-send-email-simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
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
> Allow formatting of select group action. This is used
> when pretty-printing datapath flows. Subsequent patches
> will add support for the select group action to the datapath
> and ovs-vswtichd.
> 
> Signed-off-by: Simon Horman <simon.horman-wFxRvT7yatFl57MIdRCFDg@public.gmane.org>
> ---
>  lib/odp-util.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
>  1 file changed, 67 insertions(+)
> 
> diff --git a/lib/odp-util.c b/lib/odp-util.c
> index 77b456f..4c8dd39 100644
> --- a/lib/odp-util.c
> +++ b/lib/odp-util.c
> @@ -182,6 +182,71 @@ format_odp_sample_action(struct ds *ds, const struct nlattr *attr)
>      ds_put_format(ds, "))");
>  }
>  
> +static bool
> +format_odp_bucket(struct ds *ds, const struct nlattr *attr)
> +{
> +    static const struct nl_policy ovs_sample_policy[] = {

Not that it would matter much but you might want to rename that to
ovs_bucket_policy[]. Same below.
