From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH][IPVS] Relax the module get/put in ip_vs_app.c
Date: Tue, 20 Nov 2007 11:28:18 +0900
Message-ID: <20071120022816.GL24412@verge.net.au>
References: <47415E36.8030001@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:44227 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750728AbXKTC2W (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Nov 2007 21:28:22 -0500
Content-Disposition: inline
In-Reply-To: <47415E36.8030001@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 19, 2007 at 12:58:14PM +0300, Pavel Emelyanov wrote:
> Both try_module_get/module_put already handle the module == NULL
> case, so no need in manual checking.
> 
> This patch fits both net-2.6 and net-2.6.25.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thanks, that looks fine to me.

Acked-by: Simon Horman <horms@verge.net.au>

