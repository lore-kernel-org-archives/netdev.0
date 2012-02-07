From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool v2] ethtool: Add ntuple to the -K option in the man
 page
Date: Tue, 7 Feb 2012 18:30:59 +0000
Message-ID: <1328639459.3549.15.camel@bwh-desktop>
References: <1328613644-16668-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Amir Hanania <amir.hanania@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:27289 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751818Ab2BGSbE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Feb 2012 13:31:04 -0500
In-Reply-To: <1328613644-16668-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-02-07 at 03:20 -0800, Jeff Kirsher wrote:
> From: Amir Hanania <amir.hanania@intel.com>
> 
> -v2: Added full description.
>      Made the location of ntuple consistent with the ordering in
>      'ethtool -h' output
> 
> Signed-off-by: Amir Hanania <amir.hanania@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, thanks.

Ben.

> ---
>  ethtool.8.in |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/ethtool.8.in b/ethtool.8.in
> index e6e46cc..98078ae 100644
> --- a/ethtool.8.in
> +++ b/ethtool.8.in
> @@ -214,6 +214,7 @@ ethtool \- query or control network driver and hardware settings
>  .B2 lro on off
>  .B2 rxvlan on off
>  .B2 txvlan on off
> +.B2 ntuple on off
>  .B2 rxhash on off
>  .HP
>  .B ethtool \-p|\-\-identify
> @@ -454,6 +455,9 @@ Specifies whether RX VLAN acceleration should be enabled
>  .A2 txvlan on off
>  Specifies whether TX VLAN acceleration should be enabled
>  .TP
> +.A2 ntuple on off
> +Specifies whether Rx ntuple filters and actions should be enabled
> +.TP
>  .A2 rxhash on off
>  Specifies whether receive hashing offload should be enabled
>  .TP

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
