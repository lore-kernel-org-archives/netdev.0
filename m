From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH] xen-netback: remove dead code
Date: Mon, 6 May 2013 17:10:33 +0100
Message-ID: <20130506161033.GD32539@zion.uk.xensource.com>
References: <1367854820-4129-1-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Ian Campbell <Ian.Campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:50760 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752613Ab3EFQKk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 May 2013 12:10:40 -0400
Content-Disposition: inline
In-Reply-To: <1367854820-4129-1-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 06, 2013 at 04:40:20PM +0100, Wei Liu wrote:
> The array mmap_pages is never touched in the initialization function. This is
> remnant of mapping mechanism, which does exist upstream.
> 

This patch targets net-next.


Thanks
Wei.
