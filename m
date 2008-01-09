From: Simon Horman <horms@verge.net.au>
Subject: Re: [PATCH net-2.6.25 2/6][IPVS] Switch to using ctl_paths.
Date: Wed, 9 Jan 2008 11:49:16 +0900
Message-ID: <20080109024914.GG3403@verge.net.au>
References: <47839C30.2040402@openvz.org> <47839D93.8090406@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from koto.vergenet.net ([210.128.90.7]:58492 "EHLO koto.vergenet.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751321AbYAICtV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2008 21:49:21 -0500
Content-Disposition: inline
In-Reply-To: <47839D93.8090406@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 08, 2008 at 06:58:11PM +0300, Pavel Emelyanov wrote:
> The feature of ipvs ctls is that the net/ipv4/vs path
> is common for core ipvs ctls and for two schedulers,
> so I make it exported and re-use it in modules.
> 
> Two other .c files required linux/sysctl.h to make the
> extern declaration of this path compile well.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Thanks, this looks good to me and I've confirmed that
the same entires with the same permissions exist under
/proc/sys/net/ipv4/vs before and after the change.

Acked-by: Simon Horman <horms@verge.net.au>

-- 
Horms

