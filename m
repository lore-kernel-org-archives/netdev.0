From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: patch for ixgbe-3.3.9 (out-of-tree) driver.
Date: Wed, 01 Jun 2011 13:17:22 -0700
Message-ID: <4DE69E52.5010002@intel.com>
References: <4DE67BE1.3060704@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:38071 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752849Ab1FAURu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Jun 2011 16:17:50 -0400
In-Reply-To: <4DE67BE1.3060704@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/01/2011 10:50 AM, Ben Greear wrote:
> Using 'ethtool -t ethX' with 82598 chipset causes
> kernel splats because spin-lock wasn't initialized properly.
> This can probably cause other problems, but I'm not certain
> of that.
>
> I can't tell that anyone actually watches the sourceforge list,
> so posting it here...
>
> The reason I'm using the out-of-tree driver is that a customer
> reports link bouncing when using the 82598 NIC.  They are stuck
> on a .34 kernel at the moment, so maybe it's fixed upstream already.
> At any rate, I can't reproduce the problem locally, but the 3.3.9
> driver appears to work for them.
>
> Thanks,
> Ben
>
Ben,

I will make certain this fix is incorporated into our ixgbe out-of-tree 
driver for the next release.

Thanks for the patch,

Alex
