From: Matthew J Galgoci <mgalgoci@parcelfarce.linux.theplanet.co.uk>
Subject: Re: [patch] wireless-2.6 stuff
Date: Mon, 14 Feb 2005 08:42:45 +0000 (GMT)
Message-ID: <Pine.LNX.4.58.0502140837320.3149@parcelfarce.linux.theplanet.co.uk>
References: <Pine.LNX.4.58.0502140056290.4356@parcelfarce.linux.theplanet.co.uk>
 <20050214070403.GA32480@infradead.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jgarzik@pobox.com, hch@infradead.org
To: netdev@oss.sgi.com
In-Reply-To: <20050214070403.GA32480@infradead.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 14 Feb 2005, Christoph Hellwig wrote:
> > -comment "Obsolete Wireless cards support (pre-802.11)"
> > -	depends on NET_RADIO && (INET || ISA || PCMCIA)
> > +comment "Obsolete Wireless cards support (pre-802.11) (OBSOLETE)"
> > +	depends on NET_RADIO && (INET || ISA || PCMCIA) && OBSOLETE
> 
> bad idea.  we have tons of totally outdated hardware that's not marked
> obsolete.

On the grounds that these non-standard radios weren't horribly prolific and 
were pre-802.11, I think that they should be marked as obsolete and depend
on obsolete.

Does _anyone_ here have any of these radios?
