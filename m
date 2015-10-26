From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next 4/8] xen-netback: accept an L4 or L3 skb hash
 value from the frontend
Date: Mon, 26 Oct 2015 17:05:34 +0000
Message-ID: <20151026170534.GE18674@zion.uk.xensource.com>
References: <1445423785-4654-1-git-send-email-paul.durrant@citrix.com>
 <1445423785-4654-5-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <netdev@vger.kernel.org>, <xen-devel@lists.xenproject.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Wei Liu <wei.liu2@citrix.com>
To: Paul Durrant <paul.durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [66.165.176.89] ([66.165.176.89]:19062 "EHLO SMTP.CITRIX.COM"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751429AbbJZRFp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 26 Oct 2015 13:05:45 -0400
Content-Disposition: inline
In-Reply-To: <1445423785-4654-5-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 21, 2015 at 11:36:21AM +0100, Paul Durrant wrote:
> This patch adds an indication that netback is capable of handling hash
> values passed from the frontend (see netif.h for details), and the code
> necessary to process the additional xen_netif_extra_info segment and
> set a hash on the skb.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>
> Cc: Ian Campbell <ian.campbell@citrix.com>
> Cc: Wei Liu <wei.liu2@citrix.com>

Reviewed-by: Wei Liu <wei.liu2@citrix.com>

[...]
>  
> +		/* We support hash values. */
> +		err = xenbus_printf(xbt, dev->nodename,
> +				    "feature-hash", "%d", 1);
> +		if (err) {
> +			message = "writing feature-hash";
> +			goto abort_transaction;

Feel free to retain my reviewed-by if this changes in next version.

Wei.

> +		}
> +
>  		err = xenbus_transaction_end(xbt, 0);
>  	} while (err == -EAGAIN);
>  
> -- 
> 2.1.4
