From: Al Viro <viro@ftp.linux.org.uk>
Subject: Re: [PATCH] IPv6: only modify checksum for UDP
Date: Tue, 14 Nov 2006 01:52:47 +0000
Message-ID: <20061114015247.GW29920@ftp.linux.org.uk>
References: <20061113.165058.15265737.davem@davemloft.net> <OF31924028.FDB731A2-ON88257226.0006F081-88257226.00098A71@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, brian.haley@hp.com,
	netdev@vger.kernel.org, netdev-owner@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:44200 "EHLO
	ZenIV.linux.org.uk") by vger.kernel.org with ESMTP id S1755377AbWKNBwx
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Nov 2006 20:52:53 -0500
To: David Stevens <dlstevens@us.ibm.com>
Content-Disposition: inline
In-Reply-To: <OF31924028.FDB731A2-ON88257226.0006F081-88257226.00098A71@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 13, 2006 at 05:44:12PM -0800, David Stevens wrote:
>         That's actually what I was suggesting. In 1's-complement,
> ~0 == -0 which is still 0, so barring any special case (like UDP's
> "0 means no checksum" rule), it should be equally valid for a
> packet to have 0 or ~0 as the checksum (with otherwise identical
> data)-- they are both correct, and equal to each other. That
> extra 1's-complement 0 is, of course, why UDP can have the
> special case of remapping 0->~0.
>         Since the patch was for output-side, it doesn't matter
> whether you remap 0 to ~0 or not (except for the special case),
> but a receiver technically should allow either.

Could you please take a break from your Richard B. Johnson imitations
and read the fscking RFC?
