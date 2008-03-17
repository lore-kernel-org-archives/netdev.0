From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] igb: Correctly get protocol information
Date: Mon, 17 Mar 2008 08:13:34 -0400
Message-ID: <47DE606E.7010506@garzik.org>
References: <20080307183213.23174.76224.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52400 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752395AbYCQMNg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Mar 2008 08:13:36 -0400
In-Reply-To: <20080307183213.23174.76224.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Auke Kok wrote:
> From: Mitch Williams <mitch.a.williams@intel.com>
> 
> We can't look at the socket to get protocol information. We should
> instead look directly at the packet, and hope there are no IPv6
> option headers.
> 
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/igb/igb_main.c |   21 +++++++++++++++++----
>  1 files changed, 17 insertions(+), 4 deletions(-)

applied


