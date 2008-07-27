From: David Miller <davem@davemloft.net>
Subject: Re: [pull-request] [net-2.6 PATCH 0/6] dccp: Revised ICMP / length
 fixes
Date: Sun, 27 Jul 2008 05:03:07 -0700 (PDT)
Message-ID: <20080727.050307.213455767.davem@davemloft.net>
References: <1216976578-17767-1-git-send-email-gerrit@erg.abdn.ac.uk>
	<20080725142834.GA7422@gerrit.erg.abdn.ac.uk>
	<20080726112232.GA5582@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751194AbYG0MDH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Jul 2008 08:03:07 -0400
In-Reply-To: <20080726112232.GA5582@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Sat, 26 Jul 2008 12:22:33 +0100

> Patch #1: Implements support to distinguish original from retransmitted packets.
> Patch #2: Fixes a bug - AWL was never updated. Used by the third patch.
> Patch #3: Corrects ICMPv4 sequence number check to use AWL/H instead of SWL/H.
> Patch #4: Implements the check from patch #3 for ICMPv6.
> Patch #5: Fixes minimum-required length check for ICMPv4 embedded DCCP datagrams
> Patch #6: Same as patch #5, but for ICMPv6.
> 
> 
> These patches apply to net-2.6 (BUG_TRAP conversion) and can be pulled from
> 
>       git://eden-feed.erg.abdn.ac.uk/net-2.6		(subtree `master')

Pulled, thanks Gerrit.

> If necessary, I can prepare an upload for net-next-2.6 later.

net-next-2.6 can be ignored for at least another week or so.
