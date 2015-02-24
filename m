From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCHv1 net] xen-netback: release pending index before pushing
 Tx responses
Date: Tue, 24 Feb 2015 12:03:24 +0000
Message-ID: <20150224120324.GH20083@zion.uk.xensource.com>
References: <1424776679-7509-1-git-send-email-david.vrabel@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:5164 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752135AbbBXMD0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Feb 2015 07:03:26 -0500
Content-Disposition: inline
In-Reply-To: <1424776679-7509-1-git-send-email-david.vrabel@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 24, 2015 at 11:17:59AM +0000, David Vrabel wrote:
> If the pending indexes are released /after/ pushing the Tx response
> then a stale pending index may be used if a new Tx request is
> immediately pushed by the frontend.  The may cause various WARNINGs or
> BUGs if the stale pending index is actually still in use.
> 
> Fix this by releasing the pending index before pushing the Tx
> response.
> 
> The full barrier for the pending ring update is not required since the
> the Tx response push already has a suitable write barrier.
> 
> Signed-off-by: David Vrabel <david.vrabel@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>
