From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH] Use sockfd_lookup_light in the rest of the net/socket.c
Date: Wed, 14 Nov 2007 15:47:40 -0800
Message-ID: <20071114234738.GI2368@verge.net.au>
References: <473B256A.8080104@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:37050 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752697AbXKNXrs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Nov 2007 18:47:48 -0500
Content-Disposition: inline
In-Reply-To: <473B256A.8080104@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Nov 14, 2007 at 07:42:18PM +0300, Pavel Emelyanov wrote:
> Some time ago a sockfd_lookup_light was introduced and
> most of the socket.c file was patched to use it. However
> two routines were left - sys_sendto and sys_recvfrom.
> 
> Patch them as well, since this helper does exactly what
> these two need.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

This looks correct to me.

Acked-by: Simon Horman <horms@verge.net.au>

-- 
Horms, California Edition

