From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-next v5 0/2] MPLS: Add limited GSO support
Date: Wed, 29 May 2013 11:12:26 +0900
Message-ID: <20130529021226.GD16836@verge.net.au>
References: <1369378972-22728-1-git-send-email-horms@verge.net.au>
 <20130527.225131.2103824917751166166.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dev@openvswitch.org, netdev@vger.kernel.org, jesse@nicira.com,
	pshelar@nicira.com, jarno.rajahalme@nsn.com,
	eric.dumazet@gmail.com, maze@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:60368 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753075Ab3E2C5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 22:57:10 -0400
Content-Disposition: inline
In-Reply-To: <20130527.225131.2103824917751166166.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 27, 2013 at 10:51:31PM -0700, David Miller wrote:
> From: Simon Horman <horms@verge.net.au>
> Date: Fri, 24 May 2013 16:02:50 +0900
> 
> > In the case where a non-MPLS packet is received and an MPLS stack is
> > added it may well be the case that the original skb is GSO but the
> > NIC used for transmit does not support GSO of MPLS packets.
> > 
> > The aim of this short series is to provide GSO in software for MPLS packets
> > whose skbs are GSO.
> 
> Looks good, and harmless, applied, thanks!

Thanks!


kbuild tells me that the change to use 16 bit offsets for the header
elements of skb appears to have added some build warnings. I will track
them down and fix them ASAP.
