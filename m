From: "David S. Miller" <davem@redhat.com>
Subject: Re: [PATCH][ATM]: fix sparse checker warnings
Date: Sat, 26 Jun 2004 16:26:41 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040626162641.00786ed6.davem@redhat.com>
References: <200406262245.i5QMjn65009470@ginger.cmf.nrl.navy.mil>
	<20040626225230.GA12698@taniwha.stupidest.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: chas@cmf.nrl.navy.mil, shemminger@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Chris Wedgwood <cw@f00f.org>
In-Reply-To: <20040626225230.GA12698@taniwha.stupidest.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 26 Jun 2004 15:52:30 -0700
Chris Wedgwood <cw@f00f.org> wrote:

> > +++ b/net/atm/br2684.c	2004-06-22 14:04:02 -07:00
> > @@ -562,7 +562,7 @@
> >  	atmvcc->push = br2684_push;
> >  	skb_queue_head_init(&copy);
> >  	skb_migrate(&atmvcc->sk->sk_receive_queue, &copy);
> 
> > - -	while ((skb = skb_dequeue(&copy))) {
> > +	while ((skb = skb_dequeue(&copy)) != NULL) {
> 
> I know it's a matter of style, but I really hate the 'assignment in
> conditional' warning sparse spews out, especially when many people,
> myself included really do write while ((a = b)) --- the extra
> parentheses as a compromise to keep gcc quiet.

I think warning for the ((a=b)) case is annoying but not annoying
enough to fight against it :)
