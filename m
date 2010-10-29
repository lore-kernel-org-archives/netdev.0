From: Greg KH <gregkh@suse.de>
Subject: Re: [PATCH] staging: get rid of dev_base_lock
Date: Fri, 29 Oct 2010 06:47:49 -0700
Message-ID: <20101029134749.GC20832@suse.de>
References: <1288358367.2560.38.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:40699 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756878Ab0J2NrQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 29 Oct 2010 09:47:16 -0400
Content-Disposition: inline
In-Reply-To: <1288358367.2560.38.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 29, 2010 at 03:19:27PM +0200, Eric Dumazet wrote:
> dev_base_lock was the legacy rwlock used to protect netdevice list, and
> is expected to vanish.
> 
> We now use RTNL and RCU locking.

Is this a .38 patch, or something that needs to be in .37?

thanks,

greg k-h
