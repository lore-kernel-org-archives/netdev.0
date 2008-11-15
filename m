From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [BUG] net: fix /proc/net/snmp as memory corruptor
Date: Fri, 14 Nov 2008 21:10:15 -0800
Message-ID: <20081115051015.GB26468@kroah.com>
References: <491D07E0.9010903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stable@kernel.org, "David S. Miller" <davem@davemloft.net>,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:51505 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751208AbYKOFQL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 15 Nov 2008 00:16:11 -0500
Content-Disposition: inline
In-Reply-To: <491D07E0.9010903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 14, 2008 at 06:08:48AM +0100, Eric Dumazet wrote:
> Hello Greg
> 
> A patch was submited about /proc/net/snmp being a memory corruptor and not SMP safe
> 
> (commit b971e7ac834e9f4bda96d5a96ae9abccd01c1dd8)
> 
> These bugs are present on 2.6.26 & 2.6.27.

I looking at this, it doesn't seem to apply at all to the .27 tree.  If
David doesn't object, care to backport it there and send it to
stable@kernel.org?

thanks,

greg k-h
