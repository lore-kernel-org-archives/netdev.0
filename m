From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: net: Kill skbuff macros from the stone ages.
Date: Tue, 10 Feb 2009 00:48:42 -0800 (PST)
Message-ID: <20090210.004842.253830302.davem@davemloft.net>
References: <20090210.000630.194774286.davem@davemloft.net>
	<20090210085024.GA10512@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38488
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751624AbZBJIss (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 03:48:48 -0500
In-Reply-To: <20090210085024.GA10512@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Tue, 10 Feb 2009 11:50:24 +0300

> On Tue, Feb 10, 2009 at 12:06:30AM -0800, David Miller wrote:
> > -#define HAVE_ALLOC_SKB		/* For the drivers to know */
> > -#define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */
> 
> BTW, after net_device_ops conversion will be finished, netdev HAVE_*
> macros should be deleted as well.

I agree.

To be honest the whole HAVE_* was a really dumb idea.  Althought I
suppose at the time it might have made some kind of sense.

