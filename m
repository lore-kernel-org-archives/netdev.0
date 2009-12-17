From: Greg KH <greg@kroah.com>
Subject: Re: [stable] [PATCH -stable 01/02]: ipv6: reassembly: use seperate
 reassembly queues for conntrack and local delivery
Date: Thu, 17 Dec 2009 08:26:03 -0800
Message-ID: <20091217162603.GA18720@kroah.com>
References: <4B2A4B84.9070802@trash.net>
 <20091217161421.GA31911@kroah.com>
 <4B2A59BE.2020208@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>, stable@kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kroah.org ([198.145.64.141]:34940 "EHLO coco.kroah.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753627AbZLRP15 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Dec 2009 10:27:57 -0500
Content-Disposition: inline
In-Reply-To: <4B2A59BE.2020208@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 17, 2009 at 05:18:06PM +0100, Patrick McHardy wrote:
> Greg KH wrote:
> > On Thu, Dec 17, 2009 at 04:17:24PM +0100, Patrick McHardy wrote:
> >> The following two patches for -stable fix some defragmentation bugs
> >> in netfilter which can cause the kernel to crash in the bridge
> >> netfilter code.
> >>
> >> Please apply, thanks.
> > 
> > To which -stable tree?  .32, .31, and/or .27?
> 
> The patch is based on .32, but the bug affects all versions of the
> kernel.

Thanks for letting me know, I'll queue it up for the next round of
kernels.

greg k-h
