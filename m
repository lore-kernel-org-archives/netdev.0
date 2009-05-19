From: Ajit Khaparde <ajitk@serverengines.com>
Subject: Re: [PATCH][be2net] remove napi in the tx path
Date: Tue, 19 May 2009 16:55:36 +0530
Message-ID: <20090519112534.GA26870@serverengines.com>
References: <20090519013616.GA25903@serverengines.com> <20090518.192309.109435829.davem@davemloft.net>
Reply-To: Ajit Khaparde <ajitk@serverengines.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from segment-124-30.sify.net ([124.30.166.146]:61201 "EHLO
	akhaparde.serverengines.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750831AbZESLZM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 May 2009 07:25:12 -0400
Content-Disposition: inline
In-Reply-To: <20090518.192309.109435829.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Sorry for clubbing the two unrelated items in one patch.
The patch apply failed because the previous patch has not been applied.
The module parameter for lro was being added on a request from a distro.
I will drop this change and submit another patch for doing TX completion in
interrupt context instead of through NAPI.

Thanks
Ajit

On 18/05/09 19:23 -0700, David Miller wrote:
> 
> Actually, I'm not applying this patch at all.
> 
> It's garbage.
> 
> First of all, your commit message is way too terse.  Why did
> you do these things, what are the reasons?  You don't explain
> anything.  If it's for performance reasons, you give no
> information about that.
> 
> Second of all, the change does two things.  One of which you
> don't even mention in your subject line, all of this LRO stuff.
> 
> Third of all, module parameters ARE NOT THE WAY TO CONTROL LRO!
> We have an ethtool command to turn it on and off, via the
> ethtool_ops->{set,get}_flags() methods.  So this part of your
> change is totally unacceptable.
> 
> Your patch submissions, I have to say, are horrible.  Your
> patches don't apply cleanly to the net trees, your commit
> messages are one-liners at best, and your patches do multiple
> unrelated things at the same time.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
