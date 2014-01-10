From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [net-next 14/16] i40e: enable PTP
Date: Fri, 10 Jan 2014 12:26:18 +0100
Message-ID: <20140110112618.GA32563@localhost.localdomain>
References: <1389344336-1558-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1389344336-1558-15-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, Jacob Keller <jacob.e.keller@intel.com>,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:53983 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750956AbaAJL0t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jan 2014 06:26:49 -0500
Received: by mail-ee0-f52.google.com with SMTP id d17so1854564eek.25
        for <netdev@vger.kernel.org>; Fri, 10 Jan 2014 03:26:48 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1389344336-1558-15-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 10, 2014 at 12:58:54AM -0800, Jeff Kirsher wrote:

> +/**
> + * i40e_ptp_enable - Enable/disable ancillary features of the PHC subsystem
> + * @ptp: The PTP clock structure
> + * @rq: The requested feature to change
> + * @on: Enable/disable flag
> + *
> + * The XL710 does not support any of the ancillary features of the PHY
> + * subsystem, so this function may just return.
> + **/

Typo, PHC subsystem? Otherwise, the driver looks good to me.

Acked-by: Richard Cochran <richardcochran@gmail.com>
