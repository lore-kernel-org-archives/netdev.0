From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next RFC 3/5] xen-netback: Remove old TX grant copy
 definitons
Date: Wed, 30 Oct 2013 11:13:18 +0000
Message-ID: <20131030111318.GO5221@zion.uk.xensource.com>
References: <1383094220-14775-1-git-send-email-zoltan.kiss@citrix.com>
 <1383094220-14775-4-git-send-email-zoltan.kiss@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <ian.campbell@citrix.com>, <wei.liu2@citrix.com>,
	<xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <jonathan.davies@citrix.com>
To: Zoltan Kiss <zoltan.kiss@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:42884 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982Ab3J3LNU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Oct 2013 07:13:20 -0400
Content-Disposition: inline
In-Reply-To: <1383094220-14775-4-git-send-email-zoltan.kiss@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 30, 2013 at 12:50:18AM +0000, Zoltan Kiss wrote:
> These became obsolate with grant mapping.
> 

I'm afraid not.

This TX coalescing mechanism is designed to handle the situation where
guest's MAX_SKB_FRAGS > host's MAX_SKB_FRAGS.

To a further extent, I think you might need to add mechanism for backend
to tell frontend how many frags it can handle, and frontend needs to do
necessary coalescing. Until then you can safely use this new mapping
scheme.

Wei.
