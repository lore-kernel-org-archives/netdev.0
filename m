From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH 1/2] IPv6: keep route for tentative address
Date: Mon, 24 May 2010 11:47:13 -0700
Message-ID: <20100524184713.GA8627@kroah.com>
References: <20100412154130.397252857@vyatta.com>
 <20100412154255.641453741@vyatta.com>
 <EA929A9653AAE14F841771FB1DE5A1365FE4FCE12C@rrsmsx501.amr.corp.intel.com>
 <AANLkTin3CfATS0-ePL5WUSiuq0seRCQgM6xc-YwxpPEy@mail.gmail.com>
 <20100524113118.47cc9852@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Emil S Tantilov <emils.tantilov@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	NetDev <netdev@vger.kernel.org>,
	"Tantilov, Emil S" <emil.s.tantilov@intel.com>, stable@kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:33938 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754488Ab0EXSuI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 May 2010 14:50:08 -0400
Content-Disposition: inline
In-Reply-To: <20100524113118.47cc9852@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 24, 2010 at 11:31:18AM -0700, Stephen Hemminger wrote:
> Recent changes preserve IPv6 address when link goes down (good).
> But would cause address to point to dead dst entry (bad).
> The simplest fix is to just not delete route if address is
> being held for later use.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> (cherry picked from commit 93fa159abe50d3c55c7f83622d3f5c09b6e06f4b)
> ---
> Patch is for 2.6.34-stable (problem doesn't exist in earlier kernel)

Normally I wait for David to send networking patches for the stable
trees, so I would like to get David's ack on these two before I am
willing to apply them.

thanks,

greg k-h
