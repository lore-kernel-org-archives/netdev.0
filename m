From: Alexander Duyck <alexander.h.duyck@intel.com>
Subject: Re: [PATCH net-2.6] ethtool: Compat handling for struct ethtool_rxnfc
Date: Thu, 17 Mar 2011 12:50:57 -0700
Message-ID: <4D826621.8070905@intel.com>
References: <1300383272.2569.13.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Santwona Behera <santwona.behera@sun.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:28030 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752970Ab1CQTu7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Mar 2011 15:50:59 -0400
In-Reply-To: <1300383272.2569.13.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 3/17/2011 10:34 AM, Ben Hutchings wrote:
> This structure was accidentally defined such that its layout can
> differ between 32-bit and 64-bit processes.  Add compat structure
> definitions and an ioctl wrapper function.
>
> Signed-off-by: Ben Hutchings<bhutchings@solarflare.com>
> Cc: stable@kernel.org [2.6.30+]
> ---
> David,
>
> I still haven't received any response on whether the ETHTOOL_GRXCLSRLALL
> wrapping works with a real driver, but perhaps you could test it against
> niu?  I think sparc32 and sparc64 have the same alignment for u64 so
> this wrapper isn't strictly necessary, but it would still be used.  (Or
> we can arrange to disable the conversion when compat_ethtool_rxnfc is
> equivalent to ethtool_rxnfc.)
>
> Ben.

I'll try to pull this into my current development tree and test it while 
working on the next set of RFC patches for ixgbe w/ updated flow 
director.  I probably won't have it done until the middle of next week 
though.

Thanks,

Alex
