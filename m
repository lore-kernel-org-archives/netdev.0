From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 2/2] ipv4: Restart rt_intern_hash after emergency rebuild
 (v2)
Date: Thu, 25 Mar 2010 09:17:21 -0400
Message-ID: <20100325131721.GA17675@shamino.rdu.redhat.com>
References: <4BAA4F3F.70703@openvz.org>
 <4BAB15FA.20108@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:60263 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab0CYNR2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Mar 2010 09:17:28 -0400
Content-Disposition: inline
In-Reply-To: <4BAB15FA.20108@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 25, 2010 at 10:51:22AM +0300, Pavel Emelyanov wrote:
> The the rebuild changes the genid which in turn is used at
> the hash calculation. Thus if we don't restart and go on with
> inserting the rt will happen in wrong chain.
> 
> (Fixed Neil's comment about the index passed into the rt_intern_hash)
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
Thanks!  I think this is pretty reasonable.
Reviewed-by: Neil Horman <nhorman@tuxdriver.com>

