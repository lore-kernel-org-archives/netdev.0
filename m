From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net V2] Xen-netback: Fix issue caused by using gso_type
 wrongly
Date: Mon, 10 Mar 2014 15:05:59 +0000
Message-ID: <20140310150559.GU19620@zion.uk.xensource.com>
References: <1394463514-2979-1-git-send-email-Annie.li@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<konrad.wilk@oracle.com>, <Ian.Campbell@citrix.com>,
	<wei.liu2@citrix.com>, <paul.durrant@citrix.com>
To: Annie Li <Annie.li@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:6092 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753836AbaCJPGE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Mar 2014 11:06:04 -0400
Content-Disposition: inline
In-Reply-To: <1394463514-2979-1-git-send-email-Annie.li@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 10, 2014 at 10:58:34PM +0800, Annie Li wrote:
> From: Annie Li <annie.li@oracle.com>
> 
> Current netback uses gso_type to check whether the skb contains
> gso offload, and this is wrong. Gso_size is the right one to
> check gso existence, and gso_type is only used to check gso type.
> 
> Some skbs contains nonzero gso_type and zero gso_size, current
> netback would treat these skbs as gso and create wrong response
> for this. This also causes ssh failure to domu from other server.
> 
> V2: use skb_is_gso function as Paul Durrant suggested
> 
> Signed-off-by: Annie Li <annie.li@oracle.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
