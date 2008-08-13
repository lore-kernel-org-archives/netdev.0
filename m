From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: CPU utilization increased in 2.6.27rc
Date: Wed, 13 Aug 2008 15:06:25 -0700
Message-ID: <20080813150625.30405c5f@extreme>
References: <48A23137.2010107@myri.com>
	<20080812.181549.229367205.davem@davemloft.net>
	<48A30834.4090802@myri.com>
	<18595.15208.734736.864386@robur.slu.se>
	<20080813143459.1fb1c5c5@extreme>
	<18595.22699.600206.82767@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Andrew Gallatin <gallatin@myri.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Robert Olsson <robert@robur.slu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:58426 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752133AbYHMWG1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Aug 2008 18:06:27 -0400
In-Reply-To: <18595.22699.600206.82767@robur.slu.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 13 Aug 2008 23:56:59 +0200
Robert Olsson <robert@robur.slu.se> wrote:

> 
> Stephen Hemminger writes:
>  > 
>  > I see you are still using the SLAB allocator. Does the SLUB change the numbers?
> 
>  Correct. I did try SLUB a couple month ago but got less performance
>  but there have been some SLUB patches since. Have you experimented?
> 
>  Cheers
> 					--ro
> 
>   
Not yet, but there was a movement to kill SLAB. If SLAB is still faster than
Christoph probably wants to know (and fix the problem).  The problem is that
one way flows might still be moving memory between CPU's
