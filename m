From: David Miller <davem@davemloft.net>
Subject: Re: WOL with flex filters, reflecting it in /sys
Date: Thu, 01 Oct 2009 14:22:57 -0700 (PDT)
Message-ID: <20091001.142257.125105313.davem@davemloft.net>
References: <76FA3B279DD9DA48896E2B404944957203C09587@USA7061MS02.na.xerox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-pm@lists.linux-foundation.org, netdev@vger.kernel.org,
	martyleisner@yahoo.com
To: Martin.Leisner@xerox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36062
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752687AbZJAVWi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 17:22:38 -0400
In-Reply-To: <76FA3B279DD9DA48896E2B404944957203C09587@USA7061MS02.na.xerox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Leisner, Martin" <Martin.Leisner@xerox.com>
Date: Thu, 1 Oct 2009 13:55:03 -0700

> What I'm thinking of is a hierarchy in /sys/classes/net/<device>/wol/
> 
> wol/
>    /flex-filters
>       /0
>            data -- hex data to match
>            mask -- string of 1 and 0 -- if 1, the data is valid in the
> bit 
>                    position
>       ...
>       /n
> 	   data
>          mask
>   /wake_up_packet
>   /traditional --r/w (0/1)
>      /magic_packet
>      /arp
>      /unicast
>      /multicast
>      /broadcast
>      /phy

That's a pretty hairy interface for users to learn.  Are you
really sure this is nicer than adding this facility to ethtool? :-)
