From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH net v2 1/3] xen-netback: move NAPI add/remove
 calls
Date: Mon, 11 Aug 2014 14:43:22 +0100
Message-ID: <20140811134322.GE3249@zion.uk.xensource.com>
References: <1407515833-2550-1-git-send-email-wei.liu2@citrix.com>
 <1407515833-2550-2-git-send-email-wei.liu2@citrix.com>
 <53E8B874.8070906@citrix.com>
 <53E8BBCB.50308@citrix.com>
 <53E8BE92.5070606@citrix.com>
 <53E8C1A8.4050302@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: David Vrabel <david.vrabel@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>, <netdev@vger.kernel.org>,
	<xen-devel@lists.xen.org>, Ian Campbell <ian.campbell@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:24511 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753460AbaHKNnb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 11 Aug 2014 09:43:31 -0400
Content-Disposition: inline
In-Reply-To: <53E8C1A8.4050302@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In short, there's no need to reorder disconnect logic and no need have a
dedicated loop for netif_napi_del.

Wei.
