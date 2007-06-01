From: "Jeff Haran" <jharan@Brocade.COM>
Subject: RE: ETHTOOL_GSET IOCTL on GigE links
Date: Fri, 1 Jun 2007 15:51:18 -0700
Message-ID: <46F9780F64AE9945815725F4C0C72CB80302625D@hq-exch-1.corp.brocade.com>
References: <4660A044.5090007@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linux-net@vger.kernel.org>, "netdev" <netdev@vger.kernel.org>
To: "Jeff Garzik" <jeff@garzik.org>
Return-path: <linux-net-owner@vger.kernel.org>
Content-class: urn:content-classes:message
In-Reply-To: <4660A044.5090007@garzik.org>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Jeff Garzik [mailto:jeff@garzik.org] 
> Sent: Friday, June 01, 2007 3:40 PM
> To: Jeff Haran
> Cc: linux-net@vger.kernel.org; netdev
> Subject: Re: ETHTOOL_GSET IOCTL on GigE links
> 
> Jeff Haran wrote:
> > With 10/100 Mbps links it wasn't such an issue since the 
> devices tend to
> > support the same forced speeds and duplexities as they are 
> capable of
> > negotiating, but with GigE links that's not always the 
> case, at least
> > not according to what I've read. For instance, the 
> following doc from
> > Sun http://www.sun.com/blueprints/0704/817-7526.pdf says that IEEE
> > 802.3ab says you can't force 1000Base-T over copper media 
> (see page 4),
> > whereas some other physical media allow GigE to run without
> > autonegotiation (there's apparently this "serdes" interface 
> that allows
> > it, for instance).
> > 
> > Seems like there should be another field named something like
> > supported_forced to indicate what can be forced on the 
> interface. Either
> > that or some more SUPPORTED_* bits to indicate supported 
> forced modes.
> 
> 
> The 'supported' field has nothing at all to do with auto-negotiation.
> 
> The driver should list all possibilities in that field, even 
> if some are 
> ONLY supported via 'forced' selection.
> 
> 	Jeff
> 

OK, but my question remains. In the case where a device supports one set
of speeds via autonegotiation and another set via forcing, how does one
tell which speeds can be forced and which can be autonegotiated?

Thanks,

Jeff Haran
