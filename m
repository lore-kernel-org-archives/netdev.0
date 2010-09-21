From: David Miller <davem@davemloft.net>
Subject: Re: net-next-2.6 [PATCH 0/5] dccp: miscellaneous CCID fixes and
 clean-up
Date: Tue, 21 Sep 2010 16:03:47 -0700 (PDT)
Message-ID: <20100921.160347.193718359.davem@davemloft.net>
References: <miscellaneous_dccp_ccid_fixes>
	<1285064938-5933-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45311
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751484Ab0IUXD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 19:03:28 -0400
In-Reply-To: <1285064938-5933-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Tue, 21 Sep 2010 12:28:53 +0200

> please find attached a tested set of 2 + 3 cleanup patches; 
>  * the first two affect the DCCP CCID interface in general,
>  * the last three conclude the first set of CCID-3 patches.
> 
>  Patch #1: allows the CCID option-parsing routines to see the packet type.
>  Patch #2: replaces magic CCID-specific numbers with symbolic constants.
>  Patch #3: removes a redundant CCID-3 state (thanks to Leandro Sales de Melo).
>  Patch #4: fixes several issues in computing the CCID-3 loss rate.
>  Patch #5: removes redundant CCID-3 TX 'options_received' struct.
> 
> The set has also been placed into a fresh (today's) copy of net-next-2.6, on
> 
>     git://eden-feed.erg.abdn.ac.uk/net-next-2.6        [subtree 'dccp']
> 
> All patches have been tested and compile independently.    

All looks good, pulled, thanks Gerrit!
