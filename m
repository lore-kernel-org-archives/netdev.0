From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: IFF_TX_SKB_SHARING
Date: Wed, 14 Sep 2011 07:09:42 -0400
Message-ID: <20110914110942.GA3866@hmsreliant.think-freely.org>
References: <Pine.NEB.4.64.1109141227580.19629@otaku.Xtrmntr.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Pekka Riikonen <priikone@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:51431 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756457Ab1INLJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Sep 2011 07:09:49 -0400
Content-Disposition: inline
In-Reply-To: <Pine.NEB.4.64.1109141227580.19629@otaku.Xtrmntr.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 14, 2011 at 12:38:42PM +0200, Pekka Riikonen wrote:
> 
> The IFF_TX_SKB_SHARING flag was introduced in d88733150.  Was it
> intended that it clears IFF_XMIT_DST_RELEASE flag?  It's set in
> alloc_netdev_mqs but gets cleared by ether_setup (via
> alloc_etherdev_mqs).
> 
> Thanks,
> 
> 	Pekka
> 

No, thats in error, the sharing flag was meant to be or-ed in.  I'll fix that
immediately, thanks!
Neil
