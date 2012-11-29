From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH resend net-next 2/3] myri10ge: Add vlan rx for better
 GRO perf.
Date: Thu, 29 Nov 2012 11:47:58 -0800
Message-ID: <1354218478.26201.3.camel@joe-AO722>
References: <50B68038.5000304@myri.com>
	 <20121129.131738.1067398537384405805.davem@davemloft.net>
	 <50B7B542.6090804@myri.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Gallatin <gallatin@myri.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:42306 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752356Ab2K2Tr6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2012 14:47:58 -0500
In-Reply-To: <50B7B542.6090804@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-29 at 14:19 -0500, Andrew Gallatin wrote:
> On 11/29/12 13:17, David Miller wrote:
> > From: Andrew Gallatin <gallatin@myri.com>
> > Date: Wed, 28 Nov 2012 16:20:56 -0500
> >
> >> + if ((dev->features & (NETIF_F_HW_VLAN_RX)) == NETIF_F_HW_VLAN_RX &&
> >> +	    (veh->h_vlan_proto == ntohs(ETH_P_8021Q))) {
> >> +		/* fixup csum if needed */
> >> +		if (skb->ip_summed == CHECKSUM_COMPLETE)
> >> +			skb->csum = csum_sub(skb->csum,
> >> + csum_partial(va + ETH_HLEN,
> >> + VLAN_HLEN, 0));
> >
> > This indentation looks like spaghetti, verify that this kind of error
> > doesn't exist in the rest of your patches, and resend the series.
> >
> 
> Sorry.  Emacs victim...  I'll clean it up & re-submit.  I'd stupidly
> assumed that checkpatch would verify indentation.  :(

checkpatch --strict
