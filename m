From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: PHC device sharing between PCI functions
Date: Thu, 4 Jul 2013 17:53:40 +0200
Message-ID: <20130704155339.GA15214@netboy>
References: <1372697768.2083.21.camel@bwh-desktop.uk.level5networks.com>
 <20130702142420.GC14630@netboy>
 <1372778262.1919.12.camel@bwh-desktop.uk.level5networks.com>
 <20130703183035.GA4446@netboy>
 <1372881153.1919.49.camel@bwh-desktop.uk.level5networks.com>
 <20130704053605.GC4457@netboy>
 <1372948466.1853.1.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>,
	netdev <netdev@vger.kernel.org>,
	Laurence Evans <levans@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f175.google.com ([209.85.215.175]:37385 "EHLO
	mail-ea0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752838Ab3GDPxp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Jul 2013 11:53:45 -0400
Received: by mail-ea0-f175.google.com with SMTP id z7so870591eaf.20
        for <netdev@vger.kernel.org>; Thu, 04 Jul 2013 08:53:44 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1372948466.1853.1.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 04, 2013 at 03:34:26PM +0100, Ben Hutchings wrote:
> On Thu, 2013-07-04 at 07:36 +0200, Richard Cochran wrote:
> > 
> > The aliases would not bother me, as long as the ethtool interface-to-phc
> > association works properly.
> 
> Well what would be 'properly' in this case?

If a PCIe card provides one interface eth0 and four PHC devcies
/dev/ptp0-3, then doing 'ethtool -T eth0' should show PHC index 0.

Thanks,
Richard
