From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] amd8111e: don't call napi_enable if configured w/o NAPI
Date: Fri, 23 Nov 2007 22:09:36 -0500
Message-ID: <474795F0.1040600@pobox.com>
References: <20071121124007.GB3335@dwarf.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:44327 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753671AbXKXDJm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Nov 2007 22:09:42 -0500
In-Reply-To: <20071121124007.GB3335@dwarf.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jiri Bohac wrote:
> The amd8111e network driver was broken by 
> bea3348eef27e6044b6161fd04c3152215f96411, which makes the driver
> call napi_enable() and napi_disable() even if the driver had been 
> configured without CONFIG_AMD8111E_NAPI, and thus
> netif_napi_add() had not been called on initialization.
> This triggers a BUG in napi_enable().
> 
> This patch fixes the problem. Please apply.
> 
> Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 

applied #upstream-fixes

would you consider creating and testing a patch that removed the 
non-NAPI path completely?
