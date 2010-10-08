From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: clear heap allocation for ETHTOOL_GRXCLSRLALL
Date: Fri, 08 Oct 2010 10:49:02 -0700 (PDT)
Message-ID: <20101008.104902.115943646.davem@davemloft.net>
References: <20101007200348.GA6038@outflux.net>
	<1286483338.2271.34.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kees.cook@canonical.com, linux-kernel@vger.kernel.org,
	jgarzik@redhat.com, jeffrey.t.kirsher@intel.com,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47366
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759191Ab0JHRsl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Oct 2010 13:48:41 -0400
In-Reply-To: <1286483338.2271.34.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 07 Oct 2010 21:28:58 +0100

> On Thu, 2010-10-07 at 13:03 -0700, Kees Cook wrote:
>> Calling ETHTOOL_GRXCLSRLALL with a large rule_cnt will allocate kernel
>> heap without clearing it. For the one driver (niu) that implements it,
>> it will leave the unused portion of heap unchanged and copy the full
>> contents back to userspace.
>> 
>> Cc: stable@kernel.org
>> Signed-off-by: Kees Cook <kees.cook@canonical.com>
> 
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

Applied and queued up for -stable, thanks.
