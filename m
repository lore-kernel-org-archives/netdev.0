From: David Miller <davem@davemloft.net>
Subject: Re: dccp test-tree [PATCH 0/3] ccid-2: Congestion Window
 Validation, TCP code sharing
Date: Wed, 18 Aug 2010 23:25:32 -0700 (PDT)
Message-ID: <20100818.232532.98880936.davem@davemloft.net>
References: <ccid2_cwv_dccp_test_tree>
	<1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dccp@vger.kernel.org, netdev@vger.kernel.org
To: gerrit@erg.abdn.ac.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58205
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751018Ab0HSGZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 02:25:13 -0400
In-Reply-To: <1281676901-7018-1-git-send-email-gerrit@erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 13 Aug 2010 07:21:38 +0200

> This is a small set to enhance CCID-2, consisting mainly of Congestion Window
> Validation (RFC 2681) ported over from TCP.
> 
> The first patch allows to make the TCP minimum RTO visible also to CCID-2. Since
> CCID-3 also uses RTO (in the formula and for the nofeedback timer), I wonder
> whether we should also do the same for CCID-3??
> 
> The changeset is:
> 
>   Patch #1: makes TCP's minimum-RTO code available to CCID-2
>   Patch #2: simplifies the code by using an existing function
>   Patch #3: implements CWV for CCID-2 -- largely taken from TCP
> 
> The patches have been dusted off from my development tree. They have been tested,
> though it is some time ago. Hence I'd very much appreciate review and comments.

I think these changes are wonderful.

I'll add them to net-next-2.6, thanks a lot!
