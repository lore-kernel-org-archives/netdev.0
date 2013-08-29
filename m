From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [ethtool  3/3] ethtool: add ixgbevf support for register dump
Date: Thu, 29 Aug 2013 21:57:45 +0100
Message-ID: <1377809865.5372.23.camel@bwh-desktop.uk.level5networks.com>
References: <1377648529-8297-1-git-send-email-jeffrey.t.kirsher@intel.com>
	 <1377648529-8297-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jacob Keller <jacob.e.keller@intel.com>, <netdev@vger.kernel.org>,
	<gospo@redhat.com>, <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:31073 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756152Ab3H2U5t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Aug 2013 16:57:49 -0400
In-Reply-To: <1377648529-8297-3-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-08-27 at 17:08 -0700, Jeff Kirsher wrote:
> From: Jacob Keller <jacob.e.keller@intel.com>
> 
> This patch adds support for the ixgbevf driver, which previously was printing
> out as hex dump, and in the driver via printk. This patch corrects the
> implementation to have a new ixgbevf_reg_dump function that will format the
> register output in a more human readable format.
> 
> Signed-off-by: Jacob Keller <jacob.e.keller@intel.com>
> Tested-by: Stephen Ko <stephen.s.ko@intel.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

Applied, but:

[...]
> --- /dev/null
> +++ b/ixgbevf.c
> @@ -0,0 +1,180 @@
> +/* Copyright (c) 2007 Intel Corporation */
[...]

I'm not sure whether to believe this date...

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
