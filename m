From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: [PATCH] filter: fix sparse warning for
 bpf_internal_load_pointer_neg_helper
Date: Sun, 03 Mar 2013 18:08:43 -0800
Message-ID: <1362362923.15793.84.camel@edumazet-glaptop>
References: <1362353404-27034-1-git-send-email-claudiu.ghioc@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, edumazet@google.com, dborkman@redhat.com,
	jpirko@redhat.com, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Claudiu Ghioc <claudiu.ghioc@gmail.com>
To: Claudiu Ghioc <claudiughioc@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1362353404-27034-1-git-send-email-claudiu.ghioc@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-03-04 at 01:30 +0200, Claudiu Ghioc wrote:
> Removed the following sparse warning:
> *   net/core/filter.c:48:6: warning: symbol
>     'bpf_internal_load_pointer_neg_helper' was
>     not declared. Should it be static?
> 
> Signed-off-by: Claudiu Ghioc <claudiu.ghioc@gmail.com>
> ---
>  net/core/filter.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/core/filter.c b/net/core/filter.c
> index 2e20b55..f6c907c 100644
> --- a/net/core/filter.c
> +++ b/net/core/filter.c
> @@ -45,7 +45,7 @@
>   *
>   * Exported for the bpf jit load helper.
>   */
> -void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
> +static void *bpf_internal_load_pointer_neg_helper(const struct sk_buff *skb, int k, unsigned int size)
>  {
>  	u8 *ptr = NULL;
>  

Hmm, have you read the comment ?

Also :
