From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] macvlan: proper multicast support
Date: Mon, 27 Apr 2009 02:56:34 -0700 (PDT)
Message-ID: <20090427.025634.54725702.davem@davemloft.net>
References: <20090423091425.73ed544c@s6510>
	<49F1D5EF.3020306@trash.net>
	<20090424094808.74d401d8@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46670
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1757595AbZD0J4l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 05:56:41 -0400
In-Reply-To: <20090424094808.74d401d8@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Fri, 24 Apr 2009 09:48:08 -0700

> When using macvlan's multicast packets don't get properly passed between
> macvlan's which should be logically sharing the network.  Any multicast
> packet sent on a macvlan should show up lower device and all other macvlan's.
> Likewise a multicast packet sent on lower device should be received
> by all macvlan's.
> 
> The following is one way to do it; build tested only.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

I definitely want to see what Patrick thinks of this.
