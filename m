From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel][PATCH net-next] xen-netfront: clean up code in
 xennet_release_rx_bufs
Date: Wed, 15 Jan 2014 10:07:43 +0000
Message-ID: <20140115100743.GG5698@zion.uk.xensource.com>
References: <1389307718-2845-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<konrad.wilk@oracle.com>, <ian.campbell@citrix.com>,
	<wei.liu2@citrix.com>
To: Annie Li <Annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:53379 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbaAOKHp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 15 Jan 2014 05:07:45 -0500
Content-Disposition: inline
In-Reply-To: <1389307718-2845-1-git-send-email-Annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 06:48:38AM +0800, Annie Li wrote:
> Current netfront only grants pages for grant copy, not for grant transfer, so
> remove corresponding transfer code and add receiving copy code in
> xennet_release_rx_bufs.
> 

This path seldom gets call -- not that many people unload xen-netfront
driver. If Annie has tested this patch and it works as expected I think
it's fine.

I'm not netfront maintainer but I'm happy to add
Acked-by: Wei Liu <wei.liu2@citrix.com>
if Annie confirms she's tested this patch.

Wei.
