From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 2/8] xen-netback: remove GSO information from
 xenvif_rx_meta
Date: Mon, 26 Oct 2015 17:05:24 +0000
Message-ID: <20151026170524.GC18674@zion.uk.xensource.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
 <1445423785-4654-3-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:14380 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbJZRGV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2015 13:06:21 -0400
Content-Disposition: inline
In-Reply-To: <1445423785-4654-3-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 11:36:19AM +0100, Paul Durrant wrote:
> The code in net_rx_action() that builds rx responses has direct access
> to the skb so there is no need to copy this information into the meta
> structure.
> 
> This patch removes the extraneous fields, saves space in the array and
> removes many lines of code.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>
