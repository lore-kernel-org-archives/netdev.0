From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 2/2] [e1000 VLAN] Disable vlan hw accel when promiscuous
 mode
Date: Tue, 13 Nov 2007 13:18:38 +0100
Message-ID: <4739961E.90708@trash.net>
References: <E1Irtdz-0000DX-00@gondolin.me.apana.org.au> <20071113.033611.73195922.davem@davemloft.net> <20071113120328.GB1086@gondor.apana.org.au> <20071113.040624.43544149.davem@davemloft.net> <20071113121647.GA1330@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, joonwpark81@gmail.com,
	w@1wt.eu, cfriesen@nortel.com, auke-jan.h.kok@intel.com,
	netdev@vger.kernel.org,
	djohnson+linux-kernel@sw.starentnetworks.com,
	linux-kernel@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:43725 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753676AbXKMMTV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Nov 2007 07:19:21 -0500
In-Reply-To: <20071113121647.GA1330@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> On Tue, Nov 13, 2007 at 04:06:24AM -0800, David Miller wrote:
>>> In other words we can make it so that nobody is in promiscuous
>>> mode and therefore have to disable VLAN acceleration *unless*
>>> they really want to be in that state.  In which case it would
>>> imply that they wish to see everything and therefore we should
>>> disable VLAN acceleration.
>> This is too complicated, we have multiple unicast MAC support
>> in the driver API already, let's simply use it.
> 
> Yes I agree.  People not using Patrick's new API deserves to
> get poor performance so they can switch over sooner :)
> 
> What I was trying to say above is that e1000 currently uses
> the old set_multicast_list interface (rather than dev_set_rx_mode)
> so it's not immediately obvious why we're in promiscuous mode.
> We could look at dev->promiscuity - !!uc_count but that feels a
> bit fragile.
> 
> Perhaps those who want to push this patch should be encouraged
> to convert e1000 to the new interface :)


I already posted a patch for this, not sure what happened to it.
Auke, any news on merging the secondary unicast address support?

