From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next 2/3] ptp: igb: Use the high resolution frequency
 method.
Date: Wed, 9 Nov 2016 14:15:11 +0100
Message-ID: <20161109131511.GB6491@localhost.localdomain>
References: <cover.1478526333.git.richardcochran@gmail.com>
 <b1d732324e0b1960b294e90ca5eb2a31b6559188.1478526333.git.richardcochran@gmail.com>
 <1478642646.7545.39.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "tglx@linutronix.de" <tglx@linutronix.de>,
        "Manfred.Rudigier@omicron.at" <Manfred.Rudigier@omicron.at>,
        "ulrik.debie-os@e2big.org" <ulrik.debie-os@e2big.org>,
        "stefan.sorensen@spectralink.com" <stefan.sorensen@spectralink.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        "john.stultz@linaro.org" <john.stultz@linaro.org>,
        "intel-wired-lan@lists.osuosl.org" <intel-wired-lan@lists.osuosl.org>
To: "Keller, Jacob E" <jacob.e.keller@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f53.google.com ([74.125.82.53]:34871 "EHLO
        mail-wm0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752163AbcKINPQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 08:15:16 -0500
Received: by mail-wm0-f53.google.com with SMTP id a197so306407829wmd.0
        for <netdev@vger.kernel.org>; Wed, 09 Nov 2016 05:15:15 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1478642646.7545.39.camel@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 08, 2016 at 10:04:23PM +0000, Keller, Jacob E wrote:
> Additionally, what about min/max frequency check? Wouldn't this need to
> be updated for the new adjfine operation?

In theory you might increase the max by some sub-ppb value, but we
cannot express that as the resolution of the user space interface is
in ppb, and that little extra is not important anyhow.

Thanks,
Richard
