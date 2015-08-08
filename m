From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v3 01/20] net/xen-netback: xenvif_gop_frag_copy: move GSO
 check out of the loop
Date: Sat, 8 Aug 2015 14:59:04 +0100
Message-ID: <20150808135904.GA14214@zion.uk.xensource.com>
References: <1438966019-19322-1-git-send-email-julien.grall@citrix.com>
 <1438966019-19322-2-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:27175 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932842AbbHHN7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 8 Aug 2015 09:59:07 -0400
Content-Disposition: inline
In-Reply-To: <1438966019-19322-2-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 07, 2015 at 05:46:40PM +0100, Julien Grall wrote:
> The skb doesn't change within the function. Therefore it's only
> necessary to check if we need GSO once at the beginning.
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> 

Acked-by: Wei Liu <wei.liu2@citrix.com>
