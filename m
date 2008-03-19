From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [RFC] [IPv6] spelling fix in /proc:
 /proc/sys/net/ipv6/conf/default/temp_prefered_lft
Date: Wed, 19 Mar 2008 13:52:05 -0700 (PDT)
Message-ID: <20080319.135205.125229102.davem@davemloft.net>
References: <20080319204227.GF6935@ens-lyon.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	pekkas@netcore.fi, yoshfuji@linux-ipv6.org
To: benoit.boissinot@ens-lyon.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50249
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754924AbYCSUvt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Mar 2008 16:51:49 -0400
In-Reply-To: <20080319204227.GF6935@ens-lyon.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benoit Boissinot <benoit.boissinot@ens-lyon.org>
Date: Wed, 19 Mar 2008 21:42:27 +0100

> Is there a way to fix a bad spelling in /proc ?
> 
> Here is a patch to fix all the spelling error (prefered -> preferred)
> in the ipv6 code. I didn't change the /proc name but everything else is
> changed.
> Currently you can found both spelling in the ipv6 code.
> Is it ok ?

I think this doesn't add any value.

If the procfs file name has to remain the same, which it does,
changing variable and macro names to be different will only
cause merge conflicts and pain yet have no redeeming value.
