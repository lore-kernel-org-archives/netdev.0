From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool] ethtool: Add ntuple to the -K option in the man page.
Date: Fri, 20 Jan 2012 20:49:49 +0000
Message-ID: <1327092589.2452.2.camel@bwh-desktop>
References: <1327040031-19152-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, Amir Hanania <amir.hanania@intel.com>,
	<netdev@vger.kernel.org>, <gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:8425 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753157Ab2ATUt4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 15:49:56 -0500
In-Reply-To: <1327040031-19152-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-01-19 at 22:13 -0800, Jeff Kirsher wrote:
> From: Amir Hanania <amir.hanania@intel.com>
> 
> Signed-off-by: Amir Hanania <amir.hanania@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  ethtool.8.in |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool.8.in b/ethtool.8.in
> index e6e46cc..9b8c5bc 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -212,6 +212,7 @@ ethtool \- query or control network driver and hardware settings
>  .B2 gso on off
>  .B2 gro on off
>  .B2 lro on off
> +.B2 ntuple on off
>  .B2 rxvlan on off
>  .B2 txvlan on off
>  .B2 rxhash on off

This fixes the synopsis, but there should also be a full description
further down the page.  And a nitpick: this ought to be consistent with
the ordering in 'ethtool -h' output.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
