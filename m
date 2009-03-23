From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: rndis_wlan netdev ops
Date: Mon, 23 Mar 2009 14:00:57 -0700
Message-ID: <20090323140057.0f05c103@nehalam>
References: <20090323.134318.106371116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37148 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753766AbZCWVBF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Mar 2009 17:01:05 -0400
In-Reply-To: <20090323.134318.106371116.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 23 Mar 2009 13:43:18 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> 
> This is the only driver that won't build for me with
> the netdev ops compat option disabled.
> 
> It's trying to override the ->set_mutlicast_list op value
> of it's parent device.
> 
> Did you hit this one and I just missed it or is it not handled
> yet?

yes, that is when I stopped. Mainly because it was a non-trivial
fix.

> Probably what we'll have to do for this case is allocate a
> netdev_ops copy so that the ->set_multicast_list can be set
> to a new value.  But that defeats the whole purpose of netdev
> ops so I assume you have other plans :-)

Why not just turn off the multicast bit in the device, or maybe
the hardware developer can implement set_multicast_list
