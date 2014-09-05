From: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
Subject: Re: [PATCH] rose: use %*ph specifier
Date: Fri, 05 Sep 2014 18:22:51 +0300
Message-ID: <1409930571.30155.94.camel@linux.intel.com>
References: <1409929311-3225-1-git-send-email-andriy.shevchenko@linux.intel.com>
	 <1409930226.26422.135.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-hams@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1409930226.26422.135.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2014-09-05 at 08:17 -0700, Eric Dumazet wrote:
> On Fri, 2014-09-05 at 18:01 +0300, Andy Shevchenko wrote:
> > Instead of dereference each byte let's use %*ph specifier in the printk()
> > calls.
> > 
> > Signed-off-by: Andy Shevchenko <andriy.shevchenko@linux.intel.com>
> > ---
> >  net/rose/rose_link.c | 2 +-
> >  1 file changed, 1 insertion(+), 1 deletion(-)
> > 
> > diff --git a/net/rose/rose_link.c b/net/rose/rose_link.c
> > index bc55142..ce60771 100644
> > --- a/net/rose/rose_link.c
> > +++ b/net/rose/rose_link.c
> > @@ -160,7 +160,7 @@ void rose_link_rx_restart(struct sk_buff *skb, struct rose_neigh *neigh, unsigne
> >  		break;
> >  
> >  	case ROSE_DIAGNOSTIC:
> > -		printk(KERN_WARNING "ROSE: received diagnostic #%d - %02X %02X %02X\n", skb->data[3], skb->data[4], skb->data[5], skb->data[6]);
> > +		pr_warn("ROSE: received diagnostic #%d - %4ph\n", skb->data + 3);
> >  		break;
> >  
> >  	default:
> 
> That can not be correct.

Yes, you right.

> 
> Have you even compiled this ?

Apparently not this time.


-- 
Andy Shevchenko <andriy.shevchenko@intel.com>
Intel Finland Oy

