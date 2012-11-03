From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next] net: Fix continued iteration in rtnl_bridge_getlink()
Date: Fri, 02 Nov 2012 18:42:03 -0700
Message-ID: <5094766B.1000407@intel.com>
References: <1351897012.2703.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:64215 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754231Ab2KCBmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Nov 2012 21:42:06 -0400
In-Reply-To: <1351897012.2703.17.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/2/2012 3:56 PM, Ben Hutchings wrote:
> Commit e5a55a898720096f43bc24938f8875c0a1b34cd7 ('net: create generic
> bridge ops') broke the handling of a non-zero starting index in
> rtnl_bridge_getlink() (based on the old br_dump_ifinfo()).
>
> When the starting index is non-zero, we need to increment the current
> index for each entry that we are skipping.  Also, we need to check the
> index before both cases, since we may previously have stopped
> iteration between getting information about a device from its master
> and from itself.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---

I needed to be testing with more interfaces. Its clearly broke
with >41 veth devices. This patch fixes it thanks a lot Ben!

Tested-by: John Fastabend <john.r.fastabend@intel.com>
