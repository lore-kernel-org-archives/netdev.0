From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
Subject: Re: [PATCH 0/3] NCSI VLAN Filtering Support
Date: Mon, 14 Aug 2017 11:04:16 +1000
Message-ID: <1502672656.913.1.camel@mendozajonas.com>
References: <20170811061648.19661-1-sam@mendozajonas.com>
         <20170811.144823.1928647996484981190.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        openbmc@lists.ozlabs.org, joel@jms.id.au, benh@kernel.crashing.org,
        gwshan@linux.vnet.ibm.com, ratagupt@in.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from new2-smtp.messagingengine.com ([66.111.4.224]:37225 "EHLO
        new2-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751406AbdHNBEW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 13 Aug 2017 21:04:22 -0400
In-Reply-To: <20170811.144823.1928647996484981190.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-11 at 14:48 -0700, David Miller wrote:
> From: Samuel Mendoza-Jonas <sam@mendozajonas.com>
> Date: Fri, 11 Aug 2017 16:16:45 +1000
> 
> > This series (mainly patch 3) adds VLAN filtering to the NCSI implementation.
> > A fair amount of code already exists in the NCSI stack for VLAN filtering but
> > none of it is actually hooked up. This goes the final mile and fixes a few
> > bugs in the existing code found along the way (patch 2).
> > 
> > Patch 1 adds the appropriate flag to the ftgmac100 driver to enable filtering
> > as it's a large consumer of NCSI (and what I've been testing on).
> 
> This patch series does not apply cleanly to net-next, you need to respin.

Sorry about that, silly Friday mistake :)
I noticed I've also squashed an ftgmac100 change into the wrong patch,
I'll fix that up along with the respin.

Cheers,
Sam
