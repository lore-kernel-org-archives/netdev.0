From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 3/3] ptp: derive the device name from the
 parent device
Date: Sat, 22 Sep 2012 07:46:38 +0200
Message-ID: <20120922054638.GB6124@netboy.at.omicron.at>
References: <9f2ed4a62d52182eeab86ad3dca7f6feeb68368a.1348245523.git.richardcochran@gmail.com>
 <1348247965.2521.11.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921173709.GB6129@netboy.at.omicron.at>
 <02874ECE860811409154E81DA85FBB5818BFF5B4@ORSMSX105.amr.corp.intel.com>
 <1348249258.2521.25.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921181115.GE6129@netboy.at.omicron.at>
 <1348251783.2521.42.camel@bwh-desktop.uk.solarflarecom.com>
 <20120921184035.GF6129@netboy.at.omicron.at>
 <1348254106.2521.56.camel@bwh-desktop.uk.solarflarecom.com>
 <20120922054345.GA6124@netboy.at.omicron.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Keller, Jacob E" <jacob.e.keller@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
	John Stultz <john.stultz@linaro.org>,
	"Vick, Matthew" <matthew.vick@intel.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:32797 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753262Ab2IVFqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2012 01:46:50 -0400
Received: by wgbdr13 with SMTP id dr13so1991156wgb.1
        for <netdev@vger.kernel.org>; Fri, 21 Sep 2012 22:46:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20120922054345.GA6124@netboy.at.omicron.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Sep 22, 2012 at 07:43:46AM +0200, Richard Cochran wrote:
> 
> The one case where clock_name becomes really important is when you
> have a PHY clock, like in the above example, since it provides a way
> to see that the clock is *not* related to the MAC.

I mean that a PHY clock is not a part of the MAC. Of course it is
related to the MAC by virtue of being connected to it via a MDIO bus.

Thanks,
Richard
