From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2] xen-netback: add gso_segs calculation
Date: Tue, 17 Dec 2013 22:56:29 +0000
Message-ID: <20131217225629.GA20581@zion.uk.xensource.com>
References: <1387280675-10295-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <ian.campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:22020 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751747Ab3LQW4b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 17:56:31 -0500
Content-Disposition: inline
In-Reply-To: <1387280675-10295-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 11:44:35AM +0000, Paul Durrant wrote:
> netback already has code which parses IPv4 and v6 headers to set up checksum
> offsets and these are always applied to GSO packets being sent from
> frontends. It's therefore suboptimal that GSOs are being marked
> SKB_GSO_DODGY to defer the gso_segs calculation when netback already has all
> necessary information to hand to do the calculation. This patch adds that
> calculation.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: David Vrabel <david.vrabel@citrix.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
