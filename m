From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v3] xen-netback: implement dynamic multicast
 control
Date: Tue, 2 Feb 2016 12:04:31 +0000
Message-ID: <20160202120431.GG10990@citrix.com>
References: <1454414105-13327-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:12064 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754696AbcBBMEd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Feb 2016 07:04:33 -0500
Content-Disposition: inline
In-Reply-To: <1454414105-13327-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 02, 2016 at 11:55:05AM +0000, Paul Durrant wrote:
> My recent patch to the Xen Project documents a protocol for 'dynamic
> multicast control' in netif.h. This extends the previous multicast control
> protocol to not require a shared ring reconnection to turn the feature off.
> Instead the backend watches the "request-multicast-control" key in xenstore
> and turns the feature off if the key value is written to zero.
> 
> This patch adds support for dynamic multicast control in xen-netback.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Acked-by: Wei Liu <wei.liu2@citrix.com>
