From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH] tcp: Fix RFC reference in comment
Date: Tue, 13 Jan 2015 13:36:56 -0800
Message-ID: <CAK6E8=d6NMZjyH1JFoJX_ioAdQNYCAvH-G3ja9fScwW9u2=NFQ@mail.gmail.com>
References: <1421183431-29915-1-git-send-email-dbanerje@akamai.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Debabrata Banerjee <dbanerje@akamai.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421183431-29915-1-git-send-email-dbanerje@akamai.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 13, 2015 at 1:10 PM, Debabrata Banerjee <dbanerje@akamai.com> wrote:
>
> Comment in tcp_cwnd_restart() was referencing the wrong RFC for the algorithm
> it's implementing.
>
> Signed-off-by: Debabrata Banerjee <dbanerje@akamai.com>
> ---
>  net/ipv4/tcp_output.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
> index 65caf8b..0c13f88 100644
> --- a/net/ipv4/tcp_output.c
> +++ b/net/ipv4/tcp_output.c
> @@ -139,7 +139,7 @@ static __u16 tcp_advertise_mss(struct sock *sk)
>         return (__u16)mss;
>  }
>
> -/* RFC2861. Reset CWND after idle period longer RTO to "restart window".
> +/* RFC2581 4.1. Reset CWND after idle period longer RTO to "restart window".
>   * This is the first part of cwnd validation mechanism. */
>  static void tcp_cwnd_restart(struct sock *sk, const struct dst_entry *dst)
>  {

RFC2861 resets the cwnd like in RFC2581, but the rest of the code
implements RFC2861. So I think the current comment is fine.

>
> --
> 2.2.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
