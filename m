From: David Miller <davem@davemloft.net>
Subject: Re: linux kernel's IPV6_MULTICAST_HOPS default is 64; should be 1?
Date: Tue, 04 May 2010 14:39:21 -0700 (PDT)
Message-ID: <20100504.143921.149656301.davem@davemloft.net>
References: <4BE031FA.6040006@hp.com>
	<OFD462DFA3.FF279B8C-ON88257719.0057B1F8-88257719.005914D6@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: brian.haley@hp.com, enh@google.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32934
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932428Ab0EDVjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 May 2010 17:39:14 -0400
In-Reply-To: <OFD462DFA3.FF279B8C-ON88257719.0057B1F8-88257719.005914D6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Tue, 4 May 2010 09:12:59 -0700

> But if the default is different for each destination or interface in
> the multicast case (ie, by adding conf settings for mcast), then
> it really should do late binding and leave it as "-1" in the set, right?
> That's what I thought it was already doing, but apparently not;
> I think it used to, but maybe I just didn't notice.

Unlike other people in this thread who sometimes aren't even checking
how the current code works, I checked all of the available source
control history in this area and this code has always behaved this way.

Right from day one.
