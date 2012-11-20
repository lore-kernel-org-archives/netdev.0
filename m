From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] sockopt: Change getsockopt() of
 SO_BINDTODEVICE to return an interface name
Date: Tue, 20 Nov 2012 13:58:42 -0500 (EST)
Message-ID: <20121120.135842.249477087130415954.davem@davemloft.net>
References: <50A6A8FB.3050901@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@parallels.com, eric.dumazet@gmail.com, netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751528Ab2KTS6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2012 13:58:44 -0500
In-Reply-To: <50A6A8FB.3050901@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Fri, 16 Nov 2012 15:58:35 -0500

> Instead of having the getsockopt() of SO_BINDTODEVICE return an index, which
> will then require another call like if_indextoname() to get the actual interface
> name, have it return the name directly.
> 
> This also matches the existing man page description on socket(7) which mentions
> the argument being an interface name.
> 
> If the value has not been set, zero is returned and optlen will be set to zero
> to indicate there is no interface name present.
> 
> Added a seqlock to protect this code path, and dev_ifname(), from someone
> changing the device name via dev_change_name().
> 
> v2: Added seqlock protection while copying device name.
> 
> Signed-off-by: Brian Haley <brian.haley@hp.com>

Brian I was going to apply this, but something about how you email
patches results in them being corrupted.

Go to:

http://patchwork.ozlabs.org/patch/199732/

Click on Download "mbox", and try to apply that to the net-next tree
to see what I mean.
