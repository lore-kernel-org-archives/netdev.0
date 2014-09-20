From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next PATCH 29/29] fm10k: Add support for PTP
Date: Sat, 20 Sep 2014 23:16:49 +0200
Message-ID: <20140920211647.GB5258@netboy>
References: <20140918223242.10373.27403.stgit@ahduyck-bv4.jf.intel.com>
 <20140918224042.10373.93162.stgit@ahduyck-bv4.jf.intel.com>
 <20140919173504.GA4136@localhost.localdomain>
 <541C76B8.6040708@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, nhorman@redhat.com, netdev@vger.kernel.org,
	john.fastabend@gmail.com, matthew.vick@intel.com,
	jeffrey.t.kirsher@intel.com, sassmann@redhat.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:55426 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754627AbaITVQy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Sep 2014 17:16:54 -0400
Received: by mail-we0-f175.google.com with SMTP id u57so386302wes.34
        for <netdev@vger.kernel.org>; Sat, 20 Sep 2014 14:16:53 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <541C76B8.6040708@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 19, 2014 at 11:32:24AM -0700, Alexander Duyck wrote:
> 
> Because the value cannot be adjusted directly.  The timesource for the
> switch is shared by all ports and host interfaces.  As such we have to
> maintain a software offset per host to avoid corrupting the other clocks.

So any host can set the time, but only one may adjust the frequency?

Regarding the overflow, probably you can remove the daily check, since
you only need a single clock read every 300 years, and that is
reasonable to expect in any case.

Thanks,
Richard
