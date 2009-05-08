From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: introduce a list of device addresses
 dev_addr_list (v6)
Date: Fri, 08 May 2009 16:00:08 -0700 (PDT)
Message-ID: <20090508.160008.127530143.davem@davemloft.net>
References: <20090505124827.GB3473@psychotron.englab.brq.redhat.com>
	<20090505.122718.51237316.davem@davemloft.net>
	<20090508153842.65ce3bed@s6510>
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
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32884
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751209AbZEHXAO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 19:00:14 -0400
In-Reply-To: <20090508153842.65ce3bed@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 8 May 2009 15:38:42 -0700

> Not sure if this is such a good idea since the purpose of this was to fix
> a bonding/bridging interaction, but it breaks STP on bridging.

Thanks for not paying attention... :-/

The Intel folks want to have an address list functionality so
they can public MAC addresses meant for FCOE and other purposes.

So even if the bonding bits bomb, we still need this.
