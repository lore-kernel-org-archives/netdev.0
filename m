From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [RFC PATCH 1/2] net: Add support for hardware-offloaded
 encapsulation
Date: Thu, 25 Oct 2012 23:20:35 +0100
Message-ID: <1351203635.2662.73.camel@bwh-desktop.uk.solarflarecom.com>
References: <1351189753-5912-1-git-send-email-joseph.gasparakis@intel.com>
	 <1351189753-5912-2-git-send-email-joseph.gasparakis@intel.com>
	 <20121025141656.5383dabe@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joseph Gasparakis <joseph.gasparakis@intel.com>,
	<davem@davemloft.net>, <chrisw@sous-sol.org>,
	<netdev@vger.kernel.org>,
	Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:51228 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751075Ab2JYWUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 18:20:39 -0400
In-Reply-To: <20121025141656.5383dabe@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-25 at 14:16 -0700, Stephen Hemminger wrote:
> On Thu, 25 Oct 2012 11:29:12 -0700
> Joseph Gasparakis <joseph.gasparakis@intel.com> wrote:
> 
> > @@ -19,6 +19,7 @@ enum {
> >  	NETIF_F_IP_CSUM_BIT,		/* Can checksum TCP/UDP over IPv4. */
> >  	__UNUSED_NETIF_F_1,
> >  	NETIF_F_HW_CSUM_BIT,		/* Can checksum all the packets. */
> > +	NETIF_F_HW_CSUM_ENC_BIT,	/* Can checksum all inner headers */
> >  	NETIF_F_IPV6_CSUM_BIT,		/* Can checksum TCP/UDP over IPV6 */
> >  	NETIF_F_HIGHDMA_BIT,		/* Can DMA to high memory. */
> >  	NETIF_F_FRAGLIST_BIT,		/* Scatter/gather IO. */
> > @@ -52,6 +53,8 @@ enum {
> >  	NETIF_F_NTUPLE_BIT,		/* N-tuple filters supported */
> >  	NETIF_F_RXHASH_BIT,		/* Receive hashing offload */
> >  	NETIF_F_RXCSUM_BIT,		/* Receive checksumming offload */
> > +	NETIF_F_RXCSUM_ENC_BIT,		/* Receive checksuming offload */
> > +					/* for encapsulation */
> >  	NETIF_F_NOCACHE_COPY_BIT,	/* Use no-cache copyfromuser */
> >  	NETIF_F_LOOPBACK_BIT,		/* Enable loopback */
> >  	NETIF_F_RXFCS_BIT,		/* Append FCS to skb pkt data */
> 
> Add new features at the end, or reuse __UNUSED_ bits to avoid any
> issues with binary compatibility. I don't think these bits are in any
> userspace API, maybe ethtool?

There should be no binary compatibility issue here as feature bits are
meant to be looked up by name at run-time.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
