From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH V3 net-next 02/28] ethtool: Introduce a method for
 getting time stamping capabilities.
Date: Tue, 3 Apr 2012 20:24:13 +0100
Message-ID: <1333481053.2577.36.camel@bwh-desktop.uk.solarflarecom.com>
References: <cover.1333474520.git.richardcochran@gmail.com>
	 <40ae199e9b653f8f2bff0a606e11d90b6806a4e5.1333474522.git.richardcochran@gmail.com>
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
Received: from exchange.solarflare.com ([216.237.3.220]:26285 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755535Ab2DCTYR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Apr 2012 15:24:17 -0400
In-Reply-To: <40ae199e9b653f8f2bff0a606e11d90b6806a4e5.1333474522.git.richardcochran@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-03 at 19:47 +0200, Richard Cochran wrote:
> This commit adds a new ethtool ioctl that exposes the SO_TIMESTAMPING
> capabilities of a network interface. In addition, user space programs
> can use this ioctl to discover the PTP Hardware Clock (PHC) device
> associated with the interface.
> 
> Since software receive time stamps are handled by the stack, the generic
> ethtool code can answer the query correctly in case the MAC or PHY
> drivers lack special time stamping features.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
[...]
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
