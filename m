From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [iproute2] iproute2: Add VF spoofchk command description to
 ip-link.8 man page
Date: Thu, 9 Feb 2012 15:03:11 -0800
Message-ID: <20120209150311.0f54a32e@nehalam.linuxnetplumber.net>
References: <1328822476-3405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org,
	Greg Rose <gregory.v.rose@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36467 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758498Ab2BIXDO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Feb 2012 18:03:14 -0500
In-Reply-To: <1328822476-3405-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  9 Feb 2012 13:21:16 -0800
Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:

> From: Greg Rose <gregory.v.rose@intel.com>
> 
> Add documentation for the ip link set spoof checking option.  The
> expanded text section explaining the VF commands was missing this
> text.
> 
> Signed-off-by: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  man/man8/ip-link.8 |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/man/man8/ip-link.8 b/man/man8/ip-link.8
> index e1eb948..8c63584 100644
> --- a/man/man8/ip-link.8
> +++ b/man/man8/ip-link.8
> @@ -301,6 +301,10 @@ as 0 disables VLAN tagging and filtering for the VF.
>  Setting this parameter to 0 disables rate limiting. The
>  .B vf
>  parameter must be specified.
> +
> +.sp
> +.BI spoofchk " on|off"
> +- turn packet spoof checking on or off for the specified VF.
>  .in -8
>  
>  .TP

Applied.
