From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] 2.6.29-rc* QinQ vlan trunking regression
Date: Wed, 04 Mar 2009 23:45:26 -0800 (PST)
Message-ID: <20090304.234526.185561836.davem@davemloft.net>
References: <20090304.231911.213286076.davem@davemloft.net>
	<49AF7E93.2010800@trash.net>
	<49AF7FD3.5010709@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bart@jukie.net, greearb@candelatech.com, shemminger@vyatta.com,
	dada1@cosmosbay.com, frank.blaschka@de.ibm.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38014
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750728AbZCEHpm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2009 02:45:42 -0500
In-Reply-To: <49AF7FD3.5010709@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick McHardy <kaber@trash.net>
Date: Thu, 05 Mar 2009 08:31:31 +0100

> Patrick McHardy wrote:
> > David Miller wrote:
> >> From: Patrick McHardy <kaber@trash.net>
> >> Date: Thu, 05 Mar 2009 08:12:50 +0100
> >>
> >>>> We probably need both fixes to cover everything.
> >>>>
> >>> Yes, just the second one still crashes. I'm about to retry using both.
> >>
> >> Here is the updated version just for the record:
> >>
> >> vlan: Fix vlan-in-vlan crashes.
> > This still crashes. I'll have another look at the code.
> 
> This one combined with your patch fixes the crash. The code was calling
> vlan_dev_neigh_setup recursively.
> 
> Signed-off-by: Patrick McHardy <kaber@trash.net>
> 
> (or Tested-by: in case you want to roll it into your patch).

Great work, thanks Patrick!

I'll get this all integrated and push it out to Linus.
