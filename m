From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH] virtio_net: add link status handling
Date: Fri, 12 Dec 2008 18:34:48 +1030
Message-ID: <200812121834.49464.rusty@rustcorp.com.au>
References: <1228817973.26198.1.camel@blaa> <493F336B.5010402@codemonkey.ws> <1228934084.5384.66.camel@blaa>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Anthony Liguori <anthony@codemonkey.ws>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: Mark McLoughlin <markmc@redhat.com>
Return-path: <kvm-owner@vger.kernel.org>
In-Reply-To: <1228934084.5384.66.camel@blaa>
Content-Disposition: inline
Sender: kvm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 11 December 2008 05:04:44 Mark McLoughlin wrote:
> On Tue, 2008-12-09 at 21:11 -0600, Anthony Liguori wrote:
> > Rusty Russell wrote:
> > > On Wednesday 10 December 2008 08:02:14 Anthony Liguori wrote:    
> > >> It would be nice if the virtio-net card wrote some acknowledgement that 
> > >> it has received the link status down/up events.
> > >
> > > How about of every status change event? ie. a generic virtio_pci solution?
> > 
> > A really simple way to do it would just be to have another status field 
> > that was the guest's status (verses the host requested status which the 
> > current field is).  All config reads/writes result in exits so it's easy 
> > to track.
> > 
> > Adding YA virtio event may be a little overkill.
> 
> Sounds very reasonable; that and Rusty's "mask out unknown bits"
> suggestion in the version below.

Not quite what I was after.  I've taken the original patch, added the
masking change.  I'll test here and feed to DaveM.

As far as Anthony's live migrate race, I've decided to declare with
Canutian arrogance that it Will Never Happen.

Cheers,
Rusty.
