From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [patch] wireless-2.6 stuff
Date: Mon, 14 Feb 2005 07:04:03 +0000
Message-ID: <20050214070403.GA32480@infradead.org>
References: <Pine.LNX.4.58.0502140056290.4356@parcelfarce.linux.theplanet.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jgarzik@pobox.corp, netdev@oss.sgi.com
To: Matthew J Galgoci <mgalgoci@parcelfarce.linux.theplanet.co.uk>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.58.0502140056290.4356@parcelfarce.linux.theplanet.co.uk>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> -comment "Obsolete Wireless cards support (pre-802.11)"
> -	depends on NET_RADIO && (INET || ISA || PCMCIA)
> +comment "Obsolete Wireless cards support (pre-802.11) (OBSOLETE)"
> +	depends on NET_RADIO && (INET || ISA || PCMCIA) && OBSOLETE

bad idea.  we have tons of totally outdated hardware that's not marked
obsolete.
