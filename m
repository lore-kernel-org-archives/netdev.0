From: Greg KH <greg@kroah.com>
Subject: Re: 2.6.25-git16 fails with "undefined reference to
	`compat_mc_getsockopt'"
Date: Wed, 30 Apr 2008 15:03:15 -0700
Message-ID: <20080430220315.GA11136@kroah.com>
References: <20080430204622.GA1663@kroah.com> <20080430.144906.105396672.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:51861 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765370AbYD3WD4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Apr 2008 18:03:56 -0400
Content-Disposition: inline
In-Reply-To: <20080430.144906.105396672.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 30, 2008 at 02:49:06PM -0700, David Miller wrote:
> From: Greg KH <greg@kroah.com>
> Date: Wed, 30 Apr 2008 13:46:22 -0700
> 
> > Don't know if you have seen this or not, but 2.6.25-gi16 seems to fail
> > with:
> > 	net/built-in.o: In function `ipv6_getsockopt':
> > 	(.text+0x6829c): undefined reference to `compat_mc_getsockopt'
> > 
> > I've attached my .config below if that helps any.
> 
> Known problem and there is a fix pending, sit tight.

Great, thanks for letting me know and sending the patch to Linus, I
appreciate it.

greg k-h
