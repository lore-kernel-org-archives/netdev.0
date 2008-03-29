From: Bill Fink <billfink@mindspring.com>
Subject: Re: [PATCH 3/7] [NET]: uninline dev_alloc_skb, de-bloats a lot
Date: Sat, 29 Mar 2008 00:52:26 -0400
Message-ID: <20080329005226.3fe0ea85.billfink@mindspring.com>
References: <1206621486-5408-3-git-send-email-ilpo.jarvinen@helsinki.fi>
	<200803280036.59311.vda.linux@googlemail.com>
	<20080327.175212.119805454.davem@davemloft.net>
	<200803282334.29975.vda.linux@googlemail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, ilpo.jarvinen@helsinki.fi,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, acme@redhat.com
To: Denys Vlasenko <vda.linux@googlemail.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755532AbYC2Ews@vger.kernel.org>
In-Reply-To: <200803282334.29975.vda.linux@googlemail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Typo in patch (see below):

On Fri, 28 Mar 2008, Denys Vlasenko wrote:

> On Friday 28 March 2008 01:52, David Miller wrote:
> > From: Denys Vlasenko <vda.linux@googlemail.com>
> > Date: Fri, 28 Mar 2008 00:36:59 +0100
> > 
> > > Can you add a comment which explains the intent?
> > > 
> > > +struct sk_buff *dev_alloc_skb(unsigned int length)
> > > +{
> > > +       /* There is more code here than it seems:
> > > +        * __dev_alloc_skb is an inline */
> > > +	return __dev_alloc_skb(length, GFP_ATOMIC);
> > > +}
> > > +EXPORT_SYMBOL(dev_alloc_skb);
> > 
> > I've applied his patch already, if you want this comment
> > please submit the patch to add it and also please use
> > the correct formatting of the comment.
> 
> Here it is.
> 
> Signed-off-by: Denys Vlasenko <vda.linux@googlemail.com>
> --
> vda
> 
> --- net-2.6.26/net/core/skbuff.c	Fri Mar 28 23:31:05 2008
> +++ net-2.6.26.comment/net/core/skbuff.c	Fri Mar 28 23:33:03 2008
> @@ -277,6 +277,10 @@
>   */
>  struct sk_buff *dev_alloc_skb(unsigned int length)
>  {
> +	/*
> +	 * There is more code here than it seems:
> +	 * __def_alloc_skb is an inline
               ^
               v

> +	 */
>  	return __dev_alloc_skb(length, GFP_ATOMIC);
>  }
>  EXPORT_SYMBOL(dev_alloc_skb);

						-Bill
