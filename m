From: David Miller <davem@davemloft.net>
Subject: Re: [net-2.6 PATCH 0/6] dccp: ICMP bug fixes by Wei Yongjun
Date: Fri, 25 Jul 2008 02:52:23 -0700 (PDT)
Message-ID: <20080725.025223.218154533.davem@davemloft.net>
References: <dccp_icmp_payload_bug_fixes>
	<1216976578-17767-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53895
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752712AbYGYJwY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Jul 2008 05:52:24 -0400
In-Reply-To: <1216976578-17767-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 25 Jul 2008 10:02:52 +0100

> can you please have a look at this set of ICMP/DCCP bug fixes by Wei Yongjun,
> augmented by two inter-related test tree patches that solve a related bug.
> 
> Patch #1: Provides a way to distinguish original from retransmitted packets.
> Patch #2: Fixes a bug - AWL was never updated. Needed by the third patch.
> Patch #3: Corrects ICMPv4 sequence number check to use AWL/H instead of SWL/H.
> Patch #4: Implements check from patch #3 for ICMPv6.
> Patch #5: Fixes an insufficient-length check for 

As stated in my other reply, the new ICMP length checks are buggy.
Please fix those up and resend this pull request.

Thanks.
