From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] [NETFILTER] Consolidate nf_sockopt and compat_nf_sockopt
 v2
Date: Thu, 08 Nov 2007 17:43:21 +0100
Message-ID: <47333CA9.4010809@trash.net>
References: <473025DE.1000906@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64435 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759770AbXKHQnz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Nov 2007 11:43:55 -0500
In-Reply-To: <473025DE.1000906@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Both lookup the nf_sockopt_ops object to call the get/set callbacks
> from, but they perform it in a completely similar way.
> 
> Introduce the helper for finding the ops.
> 
> Ported at the top of today's net-2.6 tree to resolve conflict
> with the patch from Alexey Dobriyan.


Applied, thanks Pavel.

