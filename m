From: Mark McLoughlin <markmc@redhat.com>
Subject: Re: [PATCH] virtio_net: add link status handling
Date: Wed, 07 Jan 2009 18:18:03 +0000
Message-ID: <1231352283.5050.76.camel@localhost.localdomain>
References: <1228817973.26198.1.camel@blaa> <493F336B.5010402@codemonkey.ws>
	 <1228934084.5384.66.camel@blaa>  <200812121834.49464.rusty@rustcorp.com.au>
Reply-To: Mark McLoughlin <markmc@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:47025 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751880AbZAGSSL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Jan 2009 13:18:11 -0500
In-Reply-To: <200812121834.49464.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

On Fri, 2008-12-12 at 18:34 +1030, Rusty Russell wrote:
> On Thursday 11 December 2008 05:04:44 Mark McLoughlin wrote:
> > On Tue, 2008-12-09 at 21:11 -0600, Anthony Liguori wrote:
> > > Rusty Russell wrote:
> > > > On Wednesday 10 December 2008 08:02:14 Anthony Liguori wrote:    
> > > >> It would be nice if the virtio-net card wrote some acknowledgement that 
> > > >> it has received the link status down/up events.
> > > >
> > > > How about of every status change event? ie. a generic virtio_pci solution?
> > > 
> > > A really simple way to do it would just be to have another status field 
> > > that was the guest's status (verses the host requested status which the 
> > > current field is).  All config reads/writes result in exits so it's easy 
> > > to track.
> > > 
> > > Adding YA virtio event may be a little overkill.
> > 
> > Sounds very reasonable; that and Rusty's "mask out unknown bits"
> > suggestion in the version below.
> 
> Not quite what I was after.  I've taken the original patch, added the
> masking change.  I'll test here and feed to DaveM.

This never got pushed to davem, did it? What you've got in your queue
looks fine to me ...

Cheers,
Mark.

