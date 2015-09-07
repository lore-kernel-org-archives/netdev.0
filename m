From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH v4 18/20] net/xen-netback: Make it running on 64KB page
 granularity
Date: Mon, 7 Sep 2015 17:57:27 +0100
Message-ID: <20150907165727.GT6436@zion.uk.xensource.com>
References: <1441640038-23615-1-git-send-email-julien.grall@citrix.com>
 <1441640038-23615-19-git-send-email-julien.grall@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>,
	<linux-arm-kernel@lists.infradead.org>, <ian.campbell@citrix.com>,
	<stefano.stabellini@eu.citrix.com>, <linux-kernel@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>
To: Julien Grall <julien.grall@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:14116 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751287AbbIGQ5a (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Sep 2015 12:57:30 -0400
Content-Disposition: inline
In-Reply-To: <1441640038-23615-19-git-send-email-julien.grall@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You might need to rebase you patch. A patch to netback went it recently.

On Mon, Sep 07, 2015 at 04:33:56PM +0100, Julien Grall wrote:
> The PV network protocol is using 4KB page granularity. The goal of this
> patch is to allow a Linux using 64KB page granularity working as a
> network backend on a non-modified Xen.
> 
> It's only necessary to adapt the ring size and break skb data in small
> chunk of 4KB. The rest of the code is relying on the grant table code.
> 
> Signed-off-by: Julien Grall <julien.grall@citrix.com>
> 

Reviewed-by: Wei Liu <wei.liu2@citrix.com>
