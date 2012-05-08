From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH 13/25] ipvs: remove check for IP_VS_CONN_F_SYNC from
 ip_vs_bind_dest
Date: Tue, 8 May 2012 11:08:44 +0900
Message-ID: <20120508020843.GA9027@verge.net.au>
References: <1336436539-5880-1-git-send-email-pablo@netfilter.org>
 <1336436539-5880-14-git-send-email-pablo@netfilter.org>
 <20120507.213607.2054696052002528963.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: pablo@netfilter.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:51535 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757762Ab2EHCIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 May 2012 22:08:47 -0400
Content-Disposition: inline
In-Reply-To: <20120507.213607.2054696052002528963.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 07, 2012 at 09:36:07PM -0400, David Miller wrote:
> From: pablo@netfilter.org
> Date: Tue,  8 May 2012 02:22:07 +0200
> 
> > +		/* It is a normal connection, so modify the counters
> > +		 * according to the flags, later the protocol can
> > +		 * update them on state change */
> 
> Rather:
> 
> 		/* It is a normal connection, so modify the counters
> 		 * according to the flags, later the protocol can
> 		 * update them on state change
> 		 */

Hi Dave,

can I fix this up as a subsequent patch?
