From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 0/2] dccp: Policy-based packet dequeueing
 interface
Date: Wed, 08 Dec 2010 10:01:29 -0800 (PST)
Message-ID: <20101208.100129.35023767.davem@davemloft.net>
References: <dccp_net_next_2_6__packet_dequeueing_interface>
	<1291621444-5927-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60103
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755089Ab0LHSBC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Dec 2010 13:01:02 -0500
In-Reply-To: <1291621444-5927-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Mon,  6 Dec 2010 08:44:02 +0100

> Hi Dave,
> 
> please find attached a self-contained 2-patch set by Tomasz which adds an API
> to influence DCCP packet dequeueing. It evolved from discussions in 2008,
> adding and adds basic building blocks for sending congestion controlled
> multimedia packets that have a priority or a deadline attached to them.
> 
> Occasionally people still make new suggestions for such an API, apparently
> overlooking the excellent work Tomasz has done and which has been in the
> test tree for two years.
> 
>  Patch #1: introduces the new policy-based packet dequeueing infrastructure.
>  Patch #2: adds parameter (sanity) checking of cmsg qpolicy parameters.
> 
> I have also placed this in into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']
> 
> The set is fully bisectable.

Looks good, pulled, thanks a lot!
