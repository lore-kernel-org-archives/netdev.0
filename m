From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFT] bridge: eliminate port_check workqueue
Date: Wed, 21 Feb 2007 13:19:27 -0800
Message-ID: <20070221131927.07328dca@freekitty>
References: <20070220221941.GA707@tv-sign.ru>
	<20070220162434.72d3ad7b@freekitty>
	<20070221082345.GB1662@ff.dom.local>
	<20070221142342.GB134@tv-sign.ru>
	<20070221105555.4d1b40a6@freekitty>
	<20070221200916.GA145@tv-sign.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jarek Poplawski <jarkao2@o2.pl>,
	Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	David Howells <dhowells@redhat.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Oleg Nesterov <oleg@tv-sign.ru>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1423143AbXBUVUt@vger.kernel.org>
In-Reply-To: <20070221200916.GA145@tv-sign.ru>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 21 Feb 2007 23:09:16 +0300
Oleg Nesterov <oleg@tv-sign.ru> wrote:

> On 02/21, Stephen Hemminger wrote:
> >
> > This is what I was suggesting by getting rid of the work queue completely.
> 
> Can't comment this patch, but if we can get rid of the work_struct - good!
> 
> > -static void port_carrier_check(struct work_struct *work)
> > +void br_port_carrier_check(struct net_bridge_port *p)
> >  {
> > -	struct net_bridge_port *p;
> > -	struct net_device *dev;
> > -	struct net_bridge *br;
> > -
> > -	dev = container_of(work, struct net_bridge_port,
> > -			   carrier_check.work)->dev;
> > -	work_release(work);
> 
> May I ask you to redo this patch on top of
> 
> 	[PATCH 1/3] net/bridge/br_if.c: don't use _WORK_NAR
> 	http://marc.theaimsgroup.com/?l=linux-kernel&m=117183517612775
> 
> ?
> 
> We are removing the _NAR stuff, it would be nice to do this in a separate
> patch.
> 
> Thanks!
> 
> Oleg.

I would rather put it in a bugfix patchset for 2.6.21 and 2.6.20-stable

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
