From: Moni Shoua <monisonlists@gmail.com>
Subject: Re: [ofa-general] Re: Re: Re: [PATCH V3 0/7] net/bonding: ADD IPoIB
 support for	the bonding driver
Date: Wed, 01 Aug 2007 17:12:26 +0300
Message-ID: <46B094CA.3080904@gmail.com>
References: <46ADDB89.5030601@voltaire.com> <adaejipr3l5.fsf@cisco.com>	<46AF3CA8.6050201@gmail.com>	<20070731140436.GA16015@mellanox.co.il>	<46AF44E0.50700@voltaire.com> <20070731142234.GC16015@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	Roland Dreier <rdreier@cisco.com>, fubar@us.ibm.com,
	general@lists.openfabrics.org, davem@davemloft.net
To: "Michael S. Tsirkin" <mst@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fwil.voltaire.com ([193.47.165.2]:13020 "EHLO exil.voltaire.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1762952AbXHAOMl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 1 Aug 2007 10:12:41 -0400
In-Reply-To: <20070731142234.GC16015@mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> It's always wrong to copy symbols from another module without
> referencing it.

Michael,
It seems like the preferred approach is to prevent ib_ipoib from being 
unloaded while bonding is on top it, right?
It seems like it would handle all safety issues (not just neigh cleanup).


