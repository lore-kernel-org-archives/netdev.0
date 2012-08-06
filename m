From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net:appletalk:ddp:fixed coding style issue relating to
Date: Mon, 06 Aug 2012 12:03:59 -0700 (PDT)
Message-ID: <20120806.120359.747789694625389454.davem@davemloft.net>
References: <1344274298-4711-1-git-send-email-ahiliation@yahoo.co.in>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: ahiliation@yahoo.co.in
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1344274298-4711-1-git-send-email-ahiliation@yahoo.co.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jeffrin Jose <ahiliation@yahoo.co.in>
Date: Mon,  6 Aug 2012 23:01:38 +0530

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

Only moving the case statement back one TAB and but not any of the
surrounding code is utterly rediculous.

This is why we hate purely coding style fixing patches.
