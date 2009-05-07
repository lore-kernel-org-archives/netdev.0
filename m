From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: bridge: use device address list instead
 of dev_addr (repost)
Date: Thu, 07 May 2009 15:03:07 -0700 (PDT)
Message-ID: <20090507.150307.195857213.davem@davemloft.net>
References: <20090415082118.GC21342@psychotron.englab.brq.redhat.com>
	<20090506144624.GI28637@psychotron.englab.brq.redhat.com>
	<20090506122645.456d9af4@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jpirko@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik@pobox.com,
	bridge@lists.linux-foundation.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com, ivecera@redhat.com
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53514
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753753AbZEGWDM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 May 2009 18:03:12 -0400
In-Reply-To: <20090506122645.456d9af4@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Wed, 6 May 2009 12:26:45 -0700

> Won't this all break spanning tree which expects 1:1 relationship
> between address and port.

Indeed, this could be a fundamental issue with this change.
