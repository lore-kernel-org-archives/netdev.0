From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool 1/3] ethtool: fix ixgbe 82598EB only registers
Date: Thu, 29 Aug 2013 21:51:10 +0100
Message-ID: <1377809470.5372.16.camel@bwh-desktop.uk.level5networks.com>
References: <1377648529-8297-1-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30930 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754354Ab3H2UvP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:51:15 -0400
In-Reply-To: <1377648529-8297-1-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-27 at 17:08 -0700, Jeff Kirsher wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch fixes ixgbe_reg_dump to only display registers specific to the
> 82598EB part, as these registers display 0xDEADBEEF otherwise, and clutter up
> the register dump.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Phil Schmitt <phillip.j.schmitt@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  ixgbe.c | 144 +++++++++++++++++++++++++++++++++-------------------------------
>  1 file changed, 75 insertions(+), 69 deletions(-)
> 
> diff --git a/ixgbe.c b/ixgbe.c
> index 9b005f2..89cb6be 100644
> --- a/ixgbe.c
> +++ b/ixgbe.c
[...]
> -	fprintf(stdout,
> -		"0x02F20: RDPROBE     (Rx Probe Mode Status)           0x%08X\n",
> -		regs_buff[1085]);
[...]

It looks like this removal really belongs to the next patch, which adds
it back with the mac_type < ixgbe_mac_X540 condition.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
