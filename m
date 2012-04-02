From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH ethtool] Add the command to show the time stamping
 capabilities.
Date: Mon, 2 Apr 2012 21:23:32 +0100
Message-ID: <1333398212.5356.29.camel@bwh-desktop.uk.solarflarecom.com>
References: <1333293808-7729-1-git-send-email-richardcochran@gmail.com>
	 <1333394758.5356.28.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>,
	Martin Porter <mporter@solarflare.com>,
	Jacob Keller <jacob.e.keller@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	<e1000-devel@lists.sourceforge.net>
To: Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27059 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751212Ab2DBUXg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 16:23:36 -0400
In-Reply-To: <1333394758.5356.28.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-02 at 20:25 +0100, Ben Hutchings wrote:
> On Sun, 2012-04-01 at 17:23 +0200, Richard Cochran wrote:
[...]
> > +	if (info->tx_types & (1 << HWTSTAMP_TX_OFF))
> > +		fprintf(stdout, "HWTSTAMP_TX_OFF\n");
> > +
> > +	if (info->tx_types & (1 << HWTSTAMP_TX_ON))
> > +		fprintf(stdout, "HWTSTAMP_TX_ON\n");
> > +
> > +	if (info->tx_types & (1 << HWTSTAMP_TX_ONESTEP_SYNC))
> > +		fprintf(stdout, "HWTSTAMP_TX_ONESTEP_SYNC\n");
> 
> If there is no hardware timestamping available then shouldn't we see
> HWTSTAMP_TX_OFF reported here?  But that's going to be the case.  Not
                                            +not

> sure whether the kernel or the ethtool utility should deal with that,
> but don't assume the ethtool utility is the only consumer.
[...]

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
