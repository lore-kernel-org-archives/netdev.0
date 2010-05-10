From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 09/11] netdev: bfin_mac: only use hardware checksum in
 normal IPv4 mode
Date: Mon, 10 May 2010 04:42:22 -0700 (PDT)
Message-ID: <20100510.044222.233422592.davem@davemloft.net>
References: <1273400337-26501-1-git-send-email-vapier@gentoo.org>
	<1273400337-26501-9-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, uclinux-dist-devel@blackfin.uclinux.org,
	jon.kowal@dspecialists.de, sonic.zhang@analog.com
To: vapier@gentoo.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57926
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756825Ab0EJLmP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 07:42:15 -0400
In-Reply-To: <1273400337-26501-9-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Frysinger <vapier@gentoo.org>
Date: Sun,  9 May 2010 06:18:55 -0400

> From: Jon Kowal <jon.kowal@dspecialists.de>
> 
> The Blackfin on-chip MAC checksum logic only works when the IP packet has
> a header length of 20 bytes.  This is true for most IPv4 packets, but not
> for IPv6 packets or IPv4 packets which use header options.  So only use
> the hardware checksum when appropriate.
> 
> Signed-off-by: Jon Kowal <jon.kowal@dspecialists.de>
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>

In order to make the tree bisectable, combine bug fixes into the changes
that add the bugs instead of letting them live in the final tree when
they don't need to.

You should have just combined this patch into the patch that added the
FCS inversion stuff.

You're going to need to respin and repost this entire patch set after
fixing all of these problems I've found.

Thanks.
