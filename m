From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] consolidate skb delivery
Date: Thu, 2 Oct 2003 12:43:45 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031002124345.7b34bf24.shemminger@osdl.org>
References: <20031002102133.7285b5ee.shemminger@osdl.org>
	<20031002192546.GA29673@wotan.suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@suse.de>
In-Reply-To: <20031002192546.GA29673@wotan.suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, 2 Oct 2003 21:25:46 +0200
Andi Kleen <ak@suse.de> wrote:

> > +static __inline__ int deliver_skb(struct sk_buff *skb,
> > +				  struct packet_type *pt_prev, int last)
> > +{
> > +	if (unlikely(!pt_prev->data))
> > +		return deliver_to_old_ones(pt_prev, skb, last);
> 
> Are there even any old style protocols left? If not you could just make
> it BUG() 
> 

bpqether,lapbether,ipconfig, and econet are still old style.
