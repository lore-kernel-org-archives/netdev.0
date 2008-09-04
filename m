From: Eddie Kohler <kohler@cs.ucla.edu>
Subject: Re: v3 [PATCH 1/1] dccp: Process incoming Change	feature-negotiation
 options
Date: Thu, 04 Sep 2008 06:23:44 -0700
Message-ID: <48BFE160.20901@cs.ucla.edu>
References: <1219339188-31873-1-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-2-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-3-git-send-email-gerrit@erg.abdn.ac.uk> <1219339188-31873-4-git-send-email-gerrit@erg.abdn.ac.uk> <20080823105647.GA15928@gerrit.erg.abdn.ac.uk> <48BCE45E.1080709@cn.fujitsu.com> <20080903042709.GB4105@gerrit.erg.abdn.ac.uk> <20080903082409.GB9001@gerrit.erg.abdn.ac.uk> <48BE829B.9000303@cs.ucla.edu> <20080903151126.GA3572@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Eddie Kohler <kohler@cs.ucla.edu>,
	Wei Yongjun <yjwei@cn.fujitsu.com>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out-66.smtp.ucla.edu ([169.232.46.167]:53972 "EHLO
	out-66.smtp.ucla.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753208AbYIDNY0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Sep 2008 09:24:26 -0400
In-Reply-To: <20080903151126.GA3572@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A ha, I understand your complaint, thank you!  This is an error in the spec 
and deserves an erratum.  The correct interpretation is to send an empty 
Confirm L.  The text of the spec should probably say "Change R and non-empty 
Confirm L options MUST NOT be sent ...".

Eddie


Gerrit Renker wrote:
> Thanks for the explanation Eddie.
>> I don't think this jump is "paradox."  DCCP's partner is asking to 
>> negotiate a non-negotiable feature, so IT doesn't think the feature is 
>> non-negotiable! (Otherwise it wouldn't have started the negotiation.)  We 
>> send an empty Confirm to slap it and tell it to get with the program.  
>> The pseudocode in section 6.6.2 indicates that an endpoint receiving an 
>> empty Confirm simply gives up the negotiation without changing the value. 
>>  This is what we want to happen.
>>
> Hm, the paradox (and that is what I was trying to raise) is in 6.3.2:
>    "Change R and Confirm L options MUST NOT be sent for non-negotiable
>     features; see Section 6.6.8."
> While the above steps seem right to me, still there is the problem that
> this step requires sending a message which is defined as invalid, i.e.
> we can not do the right thing because 6.3.2 says we must not.
> 
> Will check the patch through again, with your comments we have some
> added confirmation.
> 
> Gerrit
> 
