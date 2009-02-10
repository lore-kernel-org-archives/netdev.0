From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH]: net: Kill skbuff macros from the stone ages.
Date: Tue, 10 Feb 2009 11:50:24 +0300
Message-ID: <20090210085024.GA10512@x200.localdomain>
References: <20090210.000630.194774286.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.155]:2148 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751624AbZBJIoQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Feb 2009 03:44:16 -0500
Received: by fg-out-1718.google.com with SMTP id 16so1245439fgg.17
        for <netdev@vger.kernel.org>; Tue, 10 Feb 2009 00:44:14 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20090210.000630.194774286.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 10, 2009 at 12:06:30AM -0800, David Miller wrote:
> -#define HAVE_ALLOC_SKB		/* For the drivers to know */
> -#define HAVE_ALIGNABLE_SKB	/* Ditto 8)		   */

BTW, after net_device_ops conversion will be finished, netdev HAVE_*
macros should be deleted as well.
