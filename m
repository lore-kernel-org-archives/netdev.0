From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH V2 net-next 02/28] ethtool: Introduce a method for
 getting time stamping capabilities.
Date: Mon, 2 Apr 2012 20:04:23 +0200
Message-ID: <20120402180422.GB20984@netboy.at.omicron.at>
References: <cover.1333289292.git.richardcochran@gmail.com>
 <c212a85e0d09c1e6d38db901bcdfb605484984e9.1333289292.git.richardcochran@gmail.com>
 <1333387973.2623.15.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	e1000-devel@lists.sourceforge.net
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:50223 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751805Ab2DBSEc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 14:04:32 -0400
Received: by wibhq7 with SMTP id hq7so2933442wib.1
        for <netdev@vger.kernel.org>; Mon, 02 Apr 2012 11:04:30 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1333387973.2623.15.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 02, 2012 at 06:32:53PM +0100, Ben Hutchings wrote:
> 
> Given that this doesn't require specific support from the driver,
> shouldn't it be made to work without dev->ethtool_ops being set at all
> (as for ETHTOOL_GDRVINFO)?

I'll take a look at that.
 
> Also should it require CAP_NET_ADMIN?  I think it probably shouldn't, in
> which case you need to add it to the list of commands for which we don't
> check that.

Agreed. Tomorrow I'll repost.

Thanks,
Richard
