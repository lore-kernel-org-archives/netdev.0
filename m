From: David Miller <davem@davemloft.net>
Subject: Re: Allow group ownership of TUN/TAP devices.
Date: Mon, 02 Feb 2009 23:35:21 -0800 (PST)
Message-ID: <20090202.233521.87347951.davem@davemloft.net>
References: <498700CD.2030403@msgid.tls.msk.ru>
	<498706D2.5070003@msgid.tls.msk.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, agx@sigxcpu.org
To: mjt@tls.msk.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49630
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751981AbZBCHfY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2009 02:35:24 -0500
In-Reply-To: <498706D2.5070003@msgid.tls.msk.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Tokarev <mjt@tls.msk.ru>
Date: Mon, 02 Feb 2009 17:44:34 +0300

> Michael Tokarev wrote:
> []
> > 2, and this is the main one: How about supplementary groups?
> > 
> > Here I have a valid usage case: a group of testers running various
> > versions of windows using KVM (kernel virtual machine), 1 at a time,
> > to test some software.  kvm is set up to use bridge with a tap device
> > (there should be a way to connect to the machine).  Anyone on that group
> > has to be able to start/stop the virtual machines.
> > 
> > My first attempt - pretty obvious when I saw -g option of tunctl - is
> > to add group ownership for the tun device and add a supplementary group
> > to each user (their primary group should be different).  But that fails,
> > since kernel only checks for egid, not any other group ids.
> > 
> > What's the reasoning to not allow supplementary groups and to only check
> > for egid?
> 
> Like this.
> 
> Signed-off-by: Michael Tokarev <mjt@tls.msk.ru>

Seems reasonable, applied, thanks.
