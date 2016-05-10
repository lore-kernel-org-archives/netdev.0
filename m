From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 1/4] xen-netback: add control ring boilerplate
Date: Tue, 10 May 2016 14:29:16 +0100
Message-ID: <20160510132915.GC12241@citrix.com>
References: <1462447170-1815-1-git-send-email-paul.durrant@citrix.com>
 <1462447170-1815-2-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <xen-devel@lists.xenproject.org>, <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:63174 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750910AbcEJN3S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 May 2016 09:29:18 -0400
Content-Disposition: inline
In-Reply-To: <1462447170-1815-2-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 05, 2016 at 12:19:27PM +0100, Paul Durrant wrote:
[...]
>  
> +static int connect_ctrl_ring(struct backend_info *be)
> +{

Please use goto style error handling in this function.

Other than this the code looks good.

Wei.
