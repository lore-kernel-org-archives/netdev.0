From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] infinite recursion in netlink
Date: Wed, 25 Apr 2007 12:59:41 -0700
Message-ID: <20070425195941.GA11699@kroah.com>
References: <20070425183856.GA6028@ms2.inr.ac.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, security@kernel.org, netdev@vger.kernel.org,
	jaco@kroon.co.za
To: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canuck.infradead.org ([209.217.80.40]:46737 "EHLO
	canuck.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S2993035AbXDYUDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2007 16:03:13 -0400
Content-Disposition: inline
In-Reply-To: <20070425183856.GA6028@ms2.inr.ac.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Apr 25, 2007 at 10:38:56PM +0400, Alexey Kuznetsov wrote:
> Hello!
> 
> Reply to NETLINK_FIB_LOOKUP messages were misrouted back to kernel,
> which resulted in infinite recursion and stack overflow.
> 
> The bug is present in all kernel versions since the feature appeared.

Any hint on when this feature appeared so that we can notify the distros
for older releases?

thanks,

greg k-h
