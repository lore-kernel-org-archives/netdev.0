From: David Miller <davem@davemloft.net>
Subject: Re: [Security] TIPC security issues
Date: Wed, 27 Oct 2010 11:34:50 -0700 (PDT)
Message-ID: <20101027.113450.35054379.davem@davemloft.net>
References: <AANLkTinHVXDJbgJ0zBVRnr8R4sx=NtZCaFgbFC+8DE+q@mail.gmail.com>
	<20101027.105047.183059900.davem@davemloft.net>
	<1288203979.1836.2.camel@dan>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: torvalds@linux-foundation.org, jon.maloy@ericsson.com,
	allan.stephens@windriver.com, netdev@vger.kernel.org,
	security@kernel.org
To: drosenberg@vsecurity.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59497
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754206Ab0J0Se1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 14:34:27 -0400
In-Reply-To: <1288203979.1836.2.camel@dan>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Rosenberg <drosenberg@vsecurity.com>
Date: Wed, 27 Oct 2010 14:26:19 -0400

> The proposed fix is a start, but it's not sufficient to completely fix
> the problem.  What if the total of the iovecs wraps around back to 0?
> The total size will be returned as a small number, but large amounts of
> data will be copied into the allocated buffer since the individual
> iovecs can have arbitrary sizes.

The calculated length total is what should be used by the calling function
to decide how much to copy.

Sorry, I assumed the TIPC doing was sane like the rest of the networking.
:-(

I'll fix this up.

