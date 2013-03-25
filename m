From: David Vrabel <david.vrabel@citrix.com>
Subject: Re: [Xen-devel] [PATCH 1/6] xen-netfront: remove unused variable
 `extra'
Date: Mon, 25 Mar 2013 14:21:23 +0000
Message-ID: <51505D63.7090102@citrix.com>
References: <1364209702-12437-1-git-send-email-wei.liu2@citrix.com> <1364209702-12437-2-git-send-email-wei.liu2@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <xen-devel@lists.xen.org>, <netdev@vger.kernel.org>,
	<annie.li@oracle.com>, <david.vrabel@citrix.com>,
	<ian.campbell@citrix.com>, <konrad.wilk@oracle.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:43665 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757934Ab3CYOVZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Mar 2013 10:21:25 -0400
In-Reply-To: <1364209702-12437-2-git-send-email-wei.liu2@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25/03/13 11:08, Wei Liu wrote:
> This variable is supposed to hold reference to the last extra_info in the
> loop. However there is only type of extra info here and the loop to process
> extra info is missing, so this variable is never used and causes confusion.
> 
> Remove it at the moment. We can add it back when necessary.
> 
> Signed-off-by: Wei Liu <wei.liu2@citrix.com>

Obviously correct.

Reviewed-by: David Vrabel <david.vrabel@citrix.com>

David
