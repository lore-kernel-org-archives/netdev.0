From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: introduce a list of device addresses
 dev_addr_list (v6)
Date: Fri, 08 May 2009 16:25:55 -0700 (PDT)
Message-ID: <20090508.162555.193731410.davem@davemloft.net>
References: <20090508153842.65ce3bed@s6510>
	<20090508.160008.127530143.davem@davemloft.net>
	<20090508161204.134668b9@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	kaber@trash.net, mschmidt@redhat.com, dada1@cosmosbay.com,
	ivecera@redhat.com
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52618
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754468AbZEHX0A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 19:26:00 -0400
In-Reply-To: <20090508161204.134668b9@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 8 May 2009 16:12:04 -0700

> But the other infrastructure may have same issues (netfilter, etc).
> Just seems like it would be either to have multiple network devices
> so that upper layers could disambiguate easier.

That's quite a heavyweight solution to what is purely
an addressing issue, don't you think?

We can just revert all of that netdev_ops stuff if you
think per-netdev cost doesn't matter :-)
