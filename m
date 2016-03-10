From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 2/3] xen-netback: support multiple extra info
 fragments passed from frontend
Date: Thu, 10 Mar 2016 17:23:43 +0000
Message-ID: <20160310172343.GR31271@citrix.com>
References: <1457613028-10381-1-git-send-email-paul.durrant@citrix.com>
 <1457613028-10381-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:25229 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754740AbcCJRXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Mar 2016 12:23:38 -0500
Content-Disposition: inline
In-Reply-To: <1457613028-10381-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2016 at 12:30:27PM +0000, Paul Durrant wrote:
> The code does not currently support a frontend passing multiple extra info
> fragments to the backend in a tx request. The xenvif_get_extras() function
> handles multiple extra_info fragments but make_tx_response() assumes there
> is only ever a single extra info fragment.
> 
> This patch modifies xenvif_get_extras() to pass back a count of extra
> info fragments, which is then passed to make_tx_response() (after
> possibly being stashed in pending_tx_info for deferred responses).
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
