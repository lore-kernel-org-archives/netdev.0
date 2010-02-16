From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v2 02/12] net-caif: add CAIF socket and
 configuration headers
Date: Tue, 16 Feb 2010 15:40:52 -0800 (PST)
Message-ID: <20100216.154052.35003691.davem@davemloft.net>
References: <1266328017-28406-1-git-send-email-sjur.brandeland@stericsson.com>
	<1266328017-28406-2-git-send-email-sjur.brandeland@stericsson.com>
	<1266328017-28406-3-git-send-email-sjur.brandeland@stericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stefano.babic@babic.homelinux.org,
	randy.dunlap@oracle.com, daniel.martensson@stericsson.com,
	kaber@trash.net, marcel@holtmann.org
To: sjur.brandeland@stericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54751
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756368Ab0BPXkh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Feb 2010 18:40:37 -0500
In-Reply-To: <1266328017-28406-3-git-send-email-sjur.brandeland@stericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sjur.brandeland@stericsson.com
Date: Tue, 16 Feb 2010 14:46:47 +0100

> +#ifdef __cplusplus
> +extern "C" {
> +#endif

Sorry, we really don't make amends for C++ to use the kernel
headers in this way.

If you look at other headers defining user visible datastructures
there is really no precendence for doing what you're doing here.

Please remove these __cplusplus things and resubmit your patch
set, thank you.
