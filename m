From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH 0/8] skb fragment API: convert network drivers (part IV)
Date: Wed, 5 Oct 2011 13:25:58 -0700
Message-ID: <20111005202558.GA13436@suse.de>
References: <1317810511.21903.204.camel@zakaz.uk.xensource.com>
 <20111005191717.GC30378@suse.de>
 <20111005.161341.840183744862645286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ian.Campbell@citrix.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:42323 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756217Ab1JEUrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Oct 2011 16:47:16 -0400
Content-Disposition: inline
In-Reply-To: <20111005.161341.840183744862645286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 05, 2011 at 04:13:41PM -0400, David Miller wrote:
> From: Greg KH <gregkh@suse.de>
> Date: Wed, 5 Oct 2011 12:17:17 -0700
> 
> > On Wed, Oct 05, 2011 at 11:28:30AM +0100, Ian Campbell wrote:
> >> The following series converts a forth batch of network drivers to the
> >> SKB pages fragment API introduced in 131ea6675c76.
> >> 
> >> There are two drivers/staging patches in here. I'm not sure who normally
> >> takes these, I'm sure you guys know though.
> > 
> > I take them.  As I don't have commit 131ea6675c76 in my tree
> > (staging-next), I'd have to wait until that patch gets merged into
> > Linus's tree, which should be after 3.2-rc1, right?  Mind if I hold off
> > in taking them until then?
> 
> We're trying to change all the driver accesses so we can change
> the datastructures underneath this stuff.
> 
> If we have to wait until after 3.2-rc1, then we won't be able to
> make the datastructure change this merge window.

Then feel free to take these changes through your tree, I have no
objection to that.  I'll handle any merge issues on my side that might
happen, but given the size of these patches (i.e. almost trivial), I
doubt that would happen.

So feel free to add my:
	Acked-by: Greg Kroah-Hartman <gregkh@suse.de>

to these patches and take them through the networking tree.

thanks,

greg k-h
