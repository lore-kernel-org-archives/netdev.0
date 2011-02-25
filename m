From: Roger Luethi <rl@hellgate.ch>
Subject: Re: via-rhine -- VT6105M and checksum offloading
Date: Fri, 25 Feb 2011 08:53:03 +0100
Message-ID: <20110225075303.GA8748@core.hellgate.ch>
References: <20110224185805.GI30393@kvack.org>
 <20110224.122354.193728354.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Benjamin LaHaise <bcrl@kvack.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail13.bluewin.ch ([195.186.18.62]:44492 "EHLO
	mail13.bluewin.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755504Ab1BYIAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Feb 2011 03:00:11 -0500
Content-Disposition: inline
In-Reply-To: <20110224.122354.193728354.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 24 Feb 2011 12:23:54 -0800, David Miller wrote:
> From: Benjamin LaHaise <bcrl@kvack.org>
> Date: Thu, 24 Feb 2011 13:58:05 -0500
> 
> > Upon investigation, it looks like the VT6105M isn't actually using the 
> > hardware checksum offloading support of the hardware.  Are there any 
> > known reasons why this isn't enabled (hardware bugs?)?  I'll test enabling 
> 
> As far as I can tell it was never attempted.  So it should work.
> 
> If you do that, while you're here, you can make rhine_rx() take
> a "napi" arg and make this driver use netif_gso_receive() too.
> Don't forget to set NETIF_F_GRO or similar in netdev->flags during
> probe, and also hookup the necessary ethtool hooks.

I have a patch to enable hw checksumming (the ethtool hooks are done, but I
somehow missed the NETIF_F_GRO bit). Care to give it a whirl?

Roger

