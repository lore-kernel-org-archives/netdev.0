From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: Patch "udp: perform source validation for mcast early demux" has
 been added to the 4.13-stable tree
Date: Tue, 10 Oct 2017 09:31:43 +0200
Message-ID: <20171010073143.GA19540@kroah.com>
References: <150753453416498@kroah.com>
 <1507534651.2517.1.camel@redhat.com>
 <20171009075751.GA695@kroah.com>
 <1507536134.2517.5.camel@redhat.com>
 <20171009085458.GA20532@kroah.com>
 <1507619766.2719.14.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@vger.kernel.org, stable-commits@vger.kernel.org,
        netdev@vger.kernel.org
To: Paolo Abeni <pabeni@redhat.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linuxfoundation.org ([140.211.169.12]:41624 "EHLO
        mail.linuxfoundation.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751900AbdJJHbg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 10 Oct 2017 03:31:36 -0400
Content-Disposition: inline
In-Reply-To: <1507619766.2719.14.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 10, 2017 at 09:16:06AM +0200, Paolo Abeni wrote:
> On Mon, 2017-10-09 at 10:54 +0200, Greg KH wrote:
> > On Mon, Oct 09, 2017 at 10:02:14AM +0200, Paolo Abeni wrote:
> > > On Mon, 2017-10-09 at 09:57 +0200, Greg KH wrote:
> > > > On Mon, Oct 09, 2017 at 09:37:31AM +0200, Paolo Abeni wrote:
> > > > > On Mon, 2017-10-09 at 09:35 +0200, gregkh@linuxfoundation.org wrote:
> > > > > > This is a note to let you know that I've just added the patch titled
> > > > > > 
> > > > > >     udp: perform source validation for mcast early demux
> > > > > > 
> > > > > > to the 4.13-stable tree which can be found at:
> > > > > >     http://www.kernel.org/git/?p=linux/kernel/git/stable/stable-queue.git;a=summary
> > > > > > 
> > > > > > The filename of the patch is:
> > > > > >      udp-perform-source-validation-for-mcast-early-demux.patch
> > > > > > and it can be found in the queue-4.13 subdirectory.
> > > > > > 
> > > > > > If you, or anyone else, feels it should not be added to the stable tree,
> > > > > > please let <stable@vger.kernel.org> know about it.
> > > > > 
> > > > > Please, keep this one on-hold. It needs a relevant follow-up I'm going
> > > > > to post soon!
> > > > 
> > > > Can I keep the patch before this one in the series "IPv4: early demux
> > > > can return an error code"?  Or should I hold off on both of these for
> > > > now?
> > > 
> > > AFAIK the patch "IPv4: early demux can return an error code" does not
> > > have any issue - it's just useless without this one - I guess it can
> > > stay in.
> > 
> > Ok, I've now moved this one out, thanks for letting me know.
> > 
> > And if you happen to remember when/if a fix for this goes into the tree,
> > that would be most helpful :)
> 
> Sure! the fix just entered Linus's tree: commit 996b44fcef8f ("udp: fix
> bcast packet reception")

Great!  Dave, mind if I take this now, or do you want me to wait for the
next round of networking patches.

thanks,

greg k-h
