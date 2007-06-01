From: Jeff Garzik <jeff@garzik.org>
Subject: Re: ETHTOOL_GSET IOCTL on GigE links
Date: Fri, 01 Jun 2007 18:40:04 -0400
Message-ID: <4660A044.5090007@garzik.org>
References: <46F9780F64AE9945815725F4C0C72CB803026226@hq-exch-1.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-net@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Jeff Haran <jharan@Brocade.COM>
Return-path: <linux-net-owner@vger.kernel.org>
In-Reply-To: <46F9780F64AE9945815725F4C0C72CB803026226@hq-exch-1.corp.brocade.com>
Sender: linux-net-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Haran wrote:
> With 10/100 Mbps links it wasn't such an issue since the devices tend to
> support the same forced speeds and duplexities as they are capable of
> negotiating, but with GigE links that's not always the case, at least
> not according to what I've read. For instance, the following doc from
> Sun http://www.sun.com/blueprints/0704/817-7526.pdf says that IEEE
> 802.3ab says you can't force 1000Base-T over copper media (see page 4),
> whereas some other physical media allow GigE to run without
> autonegotiation (there's apparently this "serdes" interface that allows
> it, for instance).
> 
> Seems like there should be another field named something like
> supported_forced to indicate what can be forced on the interface. Either
> that or some more SUPPORTED_* bits to indicate supported forced modes.


The 'supported' field has nothing at all to do with auto-negotiation.

The driver should list all possibilities in that field, even if some are 
ONLY supported via 'forced' selection.

	Jeff


P.S.  netdev@linux.kernel.org is a far more active list, and is where 
the network stack/driver developers appear.
