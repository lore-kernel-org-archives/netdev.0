From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH][ATM]: fix sparse checker warnings
Date: Mon, 28 Jun 2004 20:16:28 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040629001628.GB23878@havoc.gtf.org>
References: <200406262245.i5QMjn65009470@ginger.cmf.nrl.navy.mil> <20040626225230.GA12698@taniwha.stupidest.org> <20040626162641.00786ed6.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Wedgwood <cw@f00f.org>, chas@cmf.nrl.navy.mil, shemminger@osdl.org,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20040626162641.00786ed6.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Jun 26, 2004 at 04:26:41PM -0700, David S. Miller wrote:
> On Sat, 26 Jun 2004 15:52:30 -0700
> Chris Wedgwood <cw@f00f.org> wrote:
> 
> > > +++ b/net/atm/br2684.c	2004-06-22 14:04:02 -07:00
> > > @@ -562,7 +562,7 @@
> > >  	atmvcc->push = br2684_push;
> > >  	skb_queue_head_init(&copy);
> > >  	skb_migrate(&atmvcc->sk->sk_receive_queue, &copy);
> > 
> > > - -	while ((skb = skb_dequeue(&copy))) {
> > > +	while ((skb = skb_dequeue(&copy)) != NULL) {
> > 
> > I know it's a matter of style, but I really hate the 'assignment in
> > conditional' warning sparse spews out, especially when many people,
> > myself included really do write while ((a = b)) --- the extra
> > parentheses as a compromise to keep gcc quiet.
> 
> I think warning for the ((a=b)) case is annoying but not annoying
> enough to fight against it :)

FWIW I take a tangential position on the issue:

it causes a fuckton of code churn
