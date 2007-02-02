From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH -FIX] e100: fix napi ifdefs removing needed code
Date: Fri, 02 Feb 2007 08:34:26 -0500
Message-ID: <45C33DE2.10007@garzik.org>
References: <20070131190246.23066418CB@ahkok-mobl.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org,
	"Robert P. J. Day" <rpjday@mindspring.com>,
	John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48368 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423079AbXBBNed (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Feb 2007 08:34:33 -0500
In-Reply-To: <20070131190246.23066418CB@ahkok-mobl.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Auke Kok wrote:
> e100: fix napi ifdefs removing needed code
> 
> From: Auke Kok <auke-jan.h.kok@intel.com>
> 
> The e100 driver is NAPI mode only. We need to netif_poll_disable
> during suspend and shutdown. The non-NAPI driver code was removed
> and is only avaiable in the out-of-tree e100 kernel driver.
> 
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

applied


