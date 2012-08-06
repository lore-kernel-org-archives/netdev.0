From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] net:appletalk:ddp:fixed coding style issue relating to
Date: Mon, 6 Aug 2012 18:57:29 +0100
Message-ID: <1344275849.2632.28.camel@bwh-desktop.uk.solarflarecom.com>
References: <1344274298-4711-1-git-send-email-ahiliation@yahoo.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <acme@ghostprotocols.net>, <davem@davemloft.net>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>
To: Jeffrin Jose <ahiliation@yahoo.co.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344274298-4711-1-git-send-email-ahiliation@yahoo.co.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2012-08-06 at 23:01 +0530, Jeffrin Jose wrote:
> Fixed coding style issue relating to indentation
> in net/appletalk/ddp.c found by checkpatch.pl tool.
> 
> Signed-off-by: Jeffrin Jose <ahiliation@yahoo.co.in>
> ---
>  net/appletalk/ddp.c |   26 +++++++++++++-------------
>  1 file changed, 13 insertions(+), 13 deletions(-)
> 
> diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
> index 8685296..4023fca 100644
> --- a/net/appletalk/ddp.c
> +++ b/net/appletalk/ddp.c
> @@ -1796,7 +1796,7 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
>  
>  	switch (cmd) {
>  		/* Protocol layer */
> -		case TIOCOUTQ: {
> +	case TIOCOUTQ: {
>  			long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);
>  
>  			if (amount < 0)
[...]

The whole of the switch body should be shifted left by one tab, not just
the case-labels.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
