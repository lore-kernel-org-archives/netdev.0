From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH]net:appletalk:ddp:fixed coding style issue in
 net/appletalk/ddp.c
Date: Thu, 26 Jul 2012 07:11:23 -0700
Message-ID: <1343311883.11398.21.camel@joe2Laptop>
References: <1343311142-4539-1-git-send-email-ahiliation@yahoo.co.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: acme@ghostprotocols.net, davem@davemloft.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Jeffrin Jose <ahiliation@yahoo.co.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1343311142-4539-1-git-send-email-ahiliation@yahoo.co.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2012-07-26 at 19:29 +0530, Jeffrin Jose wrote:
> Fixed coding style issue relating to switch  and case
> statement in file net/appletalk/ddp.c

Don't just move the case labels, move the code blocks
including comments.

> diff --git a/net/appletalk/ddp.c b/net/appletalk/ddp.c
[]
> @@ -1798,7 +1798,7 @@ static int atalk_ioctl(struct socket *sock, unsigned int cmd, unsigned long arg)
>  
>  	switch (cmd) {
>  		/* Protocol layer */
> -		case TIOCOUTQ: {
> +	case TIOCOUTQ: {
>  			long amount = sk->sk_sndbuf - sk_wmem_alloc_get(sk);

		long amount = etc...

Post the patch with a commit message that says that
that a git diff -w is empty and the compiled objects
are the same too.
