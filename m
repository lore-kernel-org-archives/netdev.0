From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: v3 [PATCH 1/1] dccp: Process incoming Change
	feature-negotiation options
Date: Wed, 3 Sep 2008 17:11:26 +0200
Message-ID: <20080903151126.GA3572@gerrit.erg.abdn.ac.uk>
References: <1219339188-31873-1-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-2-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-4-git-send-email-gerrit@erg.abdn.ac.uk> <20080823105647.GA15928@gerrit.erg.abdn.ac.uk> <48BCE45E.1080709@cn.fujitsu.com> <20080903042709.GB4105@gerrit.erg.abdn.ac.uk> <20080903082409.GB9001@gerrit.erg.abdn.ac.uk> <48BE829B.9000303@cs.ucla.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
To: Eddie Kohler <kohler@cs.ucla.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:55267 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753072AbYICPLr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Sep 2008 11:11:47 -0400
Content-Disposition: inline
In-Reply-To: <48BE829B.9000303@cs.ucla.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for the explanation Eddie.
>
> I don't think this jump is "paradox."  DCCP's partner is asking to 
> negotiate a non-negotiable feature, so IT doesn't think the feature is 
> non-negotiable! (Otherwise it wouldn't have started the negotiation.)  We 
> send an empty Confirm to slap it and tell it to get with the program.  
> The pseudocode in section 6.6.2 indicates that an endpoint receiving an 
> empty Confirm simply gives up the negotiation without changing the value. 
>  This is what we want to happen.
>
Hm, the paradox (and that is what I was trying to raise) is in 6.3.2:
   "Change R and Confirm L options MUST NOT be sent for non-negotiable
    features; see Section 6.6.8."
While the above steps seem right to me, still there is the problem that
this step requires sending a message which is defined as invalid, i.e.
we can not do the right thing because 6.3.2 says we must not.

Will check the patch through again, with your comments we have some
added confirmation.

Gerrit

