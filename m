From: David Miller <davem@davemloft.net>
Subject: Re: [RFT PATCH] 8139cp: properly support change of MTU values [v2]
Date: Mon, 03 Dec 2012 13:52:00 -0500 (EST)
Message-ID: <20121203.135200.1242505353532930826.davem@davemloft.net>
References: <1354551573-23721-1-git-send-email-jogreene@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jogreene@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39387 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750828Ab2LCSwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:52:02 -0500
In-Reply-To: <1354551573-23721-1-git-send-email-jogreene@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Greene <jogreene@redhat.com>
Date: Mon,  3 Dec 2012 11:19:33 -0500

> The 8139cp driver has a change_mtu function that has not been
> enabled since the dawn of the git repository. However, the
> generic eth_change_mtu is not used in its place, so that
> invalid MTU values can be set on the interface.
> 
> Original patch salvages the broken code for the single case of
> setting the MTU while the interface is down, which is safe
> and also includes the range check.  Now enhanced to support up
> or down interface.
> 
> v2: fix case where rxbufsz isn't changed in the up state case
> 
> Original patch from
> http://lkml.indiana.edu/hypermail/linux/kernel/1202.2/00770.html
> 
> Testing: has been test on virtual 8139cp setup without issue,
> have no access real hardware 8139cp, need testing help.
> 
> Signed-off-by: "John Greene" <jogreene@redhat.com>

I've applied this to net-next, if it triggers any problems we have
some time to work it out before 3.8 is released.
