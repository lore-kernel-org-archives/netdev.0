From: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Subject: Re: [PATCH 3.13] core, nfqueue, openvswitch: Orphan frags in
 skb_zerocopy and handle errors
Date: Tue, 29 Jul 2014 16:36:15 -0700
Message-ID: <20140729233615.GA28154@kroah.com>
References: <1395873465-22282-1-git-send-email-zoltan.kiss@citrix.com>
 <20140327.152956.1528740039185894234.davem@davemloft.net>
 <20140421112601.GC3200@hercules>
 <1398181118.3624.203.camel@deadeye.wl.decadent.org.uk>
 <5356AEBF.5010505@citrix.com>
 <1398194284.7767.101.camel@deadeye.wl.decadent.org.uk>
 <1402070467.23860.1.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Zoltan Kiss <zoltan.kiss@citrix.com>,
	netfilter-devel@vger.kernel.org, netfilter@vger.kernel.org,
	netdev <netdev@vger.kernel.org>, stable <stable@vger.kernel.org>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netfilter-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1402070467.23860.1.camel@deadeye.wl.decadent.org.uk>
Sender: netfilter-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 06, 2014 at 05:01:07PM +0100, Ben Hutchings wrote:
> [Trimmed cc list; added Greg and stable]
> 
> On Tue, 2014-04-22 at 20:18 +0100, Ben Hutchings wrote:
> > From: Zoltan Kiss <zoltan.kiss@citrix.com>
> > 
> > commit 36d5fe6a000790f56039afe26834265db0a3ad4c upstream.
> > 
> > skb_zerocopy can copy elements of the frags array between skbs, but it doesn't
> > orphan them. Also, it doesn't handle errors, so this patch takes care of that
> > as well, and modify the callers accordingly. skb_tx_error() is also added to
> > the callers so they will signal the failed delivery towards the creator of the
> > skb.
> > 
> > Signed-off-by: Zoltan Kiss <zoltan.kiss@citrix.com>
> > Signed-off-by: David S. Miller <davem@davemloft.net>
> > [bwh: Backported to 3.13: skb_zerocopy() is new in 3.14, but was moved from a
> >  static function in nfnetlink_queue.  We need to patch that and its caller, but
> >  not openvswitch.]
> > Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> 
> I noticed this is still not applied or queued for the 3.10.y branch, but
> it does seem to be needed.

Thanks, I've queued this up for 3.10-stable.

greg k-h
