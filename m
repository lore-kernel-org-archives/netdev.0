From: Chris Wedgwood <cw@f00f.org>
Subject: Re: [PATCH][ATM]: fix sparse checker warnings
Date: Sat, 26 Jun 2004 15:52:30 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040626225230.GA12698@taniwha.stupidest.org>
References: <200406262245.i5QMjn65009470@ginger.cmf.nrl.navy.mil>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, Stephen Hemminger <shemminger@osdl.org>,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "chas williams (contractor)" <chas@cmf.nrl.navy.mil>
Content-Disposition: inline
In-Reply-To: <200406262245.i5QMjn65009470@ginger.cmf.nrl.navy.mil>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 26, 2004 at 06:45:50PM -0400, chas williams (contractor) wrote:

> diff -Nru a/net/atm/br2684.c b/net/atm/br2684.c
> - --- a/net/atm/br2684.c	2004-06-22 14:04:02 -07:00

forwarding mangled the patch

> +++ b/net/atm/br2684.c	2004-06-22 14:04:02 -07:00
> @@ -562,7 +562,7 @@
>  	atmvcc->push = br2684_push;
>  	skb_queue_head_init(&copy);
>  	skb_migrate(&atmvcc->sk->sk_receive_queue, &copy);

> - -	while ((skb = skb_dequeue(&copy))) {
> +	while ((skb = skb_dequeue(&copy)) != NULL) {

I know it's a matter of style, but I really hate the 'assignment in
conditional' warning sparse spews out, especially when many people,
myself included really do write while ((a = b)) --- the extra
parentheses as a compromise to keep gcc quiet.


   --cw
