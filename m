From: Oliver Schinagl <oliver+list@schinagl.nl>
Subject: Re: [PATCH 0/5] ARM: sunxi: Add support for A10 Ethernet controller
Date: Tue, 19 Mar 2013 09:47:10 +0000 (UTC)
Message-ID: <loom.20130319T104406-67@post.gmane.org>
References: <1363380605-6577-1-git-send-email-maxime.ripard@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from plane.gmane.org ([80.91.229.3]:37985 "EHLO plane.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754702Ab3CSS3o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Mar 2013 14:29:44 -0400
Received: from list by plane.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1UI1IS-0006gU-4g
	for netdev@vger.kernel.org; Tue, 19 Mar 2013 19:30:04 +0100
Received: from 7of9.schinagl.nl ([88.159.158.68])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 19:30:04 +0100
Received: from oliver+list by 7of9.schinagl.nl with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Tue, 19 Mar 2013 19:30:04 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Maxime Ripard <maxime.ripard <at> free-electrons.com> writes:

> 
> Hi,
> 
> The Allwinner A10 SoC has an ethernet that is said to be coming from
> Davicom embedded in it. This IP has no public documentation, so exact
> details are quite sparse, and this code come from refactored allwinner
> code.
As we discussed on #linux-sunxi, it may be davicom IP it also may not be.
Register address do not match at all, so it could be that it is only partial
davicom IP at best.

I therefore suggest we put it in kernel/drivers/net/ethernet/allwinner/ and name
the modules/files sunxi-emac.c and sunxi-gmac.c (for the new gigabit mac in the
newest SoC's)...


Thanks,
Oliver
> 
> Since we don't have any clock support yet for the Allwinner SoCs, we
> rely on the bootloader to enable the wemac clock.
> 
> Thanks,
> Maxime
