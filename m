From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: clear heap allocations for privileged ethtool
 actions
Date: Mon, 11 Oct 2010 12:24:33 -0700 (PDT)
Message-ID: <20101011.122433.28818013.davem@davemloft.net>
References: <20101007211004.GA20267@outflux.net>
	<1286487284.2271.37.camel@achroite.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kees.cook@canonical.com, linux-kernel@vger.kernel.org,
	jgarzik@redhat.com, jeffrey.t.kirsher@intel.com,
	peter.p.waskiewicz.jr@intel.com, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45932
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755233Ab0JKTYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Oct 2010 15:24:11 -0400
In-Reply-To: <1286487284.2271.37.camel@achroite.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 07 Oct 2010 22:34:44 +0100

> On Thu, 2010-10-07 at 14:10 -0700, Kees Cook wrote:
>> Several other ethtool functions leave heap uncleared (potentially) by
>> drivers. Some interfaces appear safe (eeprom, etc), in that the sizes
>> are well controlled. In some situations (e.g. unchecked error conditions),
>> the heap will remain unchanged in areas before copying back to userspace.
>> Note that these are less of an issue since these all require CAP_NET_ADMIN.
>> 
>> Cc: stable@kernel.org
>> Signed-off-by: Kees Cook <kees.cook@canonical.com>
 ...
> Acked-by: Ben Hutchings <bhutchings@solarflare.com>

So I've applied Kees's patch to net-2.6, and I'll merge net-2.6
into net-next-2.6 so I can resolve the vmalloc/kzalloc merge
conflict before Stephen Rothwell and others have to deal with it
in -next.

Thanks!
