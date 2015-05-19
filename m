From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [RFC PATCH 02/13] xen-netback: xenbus feature persistent support
Date: Tue, 19 May 2015 16:19:29 +0100
Message-ID: <20150519151929.GA26335@zion.uk.xensource.com>
References: <1431451117-70051-1-git-send-email-joao.martins@neclab.eu>
 <1431451117-70051-3-git-send-email-joao.martins@neclab.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	<wei.liu2@citrix.com>, <ian.campbell@citrix.com>,
	<david.vrabel@citrix.com>, <boris.ostrovsky@oracle.com>,
	<konrad.wilk@oracle.com>
To: Joao Martins <joao.martins@neclab.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:16830 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757042AbbESPUk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 May 2015 11:20:40 -0400
Content-Disposition: inline
In-Reply-To: <1431451117-70051-3-git-send-email-joao.martins@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 12, 2015 at 07:18:26PM +0200, Joao Martins wrote:
> Checks for "feature-persistent" that indicates persistent grants
> support. Adds max_persistent_grants module param that specifies the max
> number of persistent grants, which if set to zero disables persistent
> grants.
> 
> Signed-off-by: Joao Martins <joao.martins@neclab.eu>

This patch needs to be moved later. The feature needs to be implemented
first.

Also you need to patch netif.h to document this new feature. To do this,
you need to patch the master netif.h in Xen tree then sync the change to
Linux. Of course I don't mind if we discuss wording in the Linux
copy then you devise a patch for Xen.

Wei.
