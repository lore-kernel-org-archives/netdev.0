From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PHC device sharing between PCI functions
Date: Thu, 4 Jul 2013 07:36:05 +0200
Message-ID: <20130704053605.GC4457@netboy>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
 <20130702142420.GC14630@netboy>
 <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
 <20130703183035.GA4446@netboy>
 <1372881153.1919.49.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Laurence Evans <levans@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f179.google.com ([74.125.82.179]:39705 "EHLO
	mail-we0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754894Ab3GDFgR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 01:36:17 -0400
Received: by mail-we0-f179.google.com with SMTP id w59so743732wes.38
        for <netdev@vger.kernel.org>; Wed, 03 Jul 2013 22:36:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1372881153.1919.49.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 03, 2013 at 08:52:33PM +0100, Ben Hutchings wrote:
> 
> So you think each function should have its own clock device, but it's
> only writable on one?  I think that would work, but I thought it would
> be undesirable to have multiple aliases for the same physical clock.

The aliases would not bother me, as long as the ethtool interface-to-phc
association works properly. Of course, if there is a way to suppress
the aliases in the non-VM case, that would be ideal.

Thanks,
Richard
