From: James Morris <jmorris@namei.org>
Subject: Re: [PATCH] Add xfrm policy change auditing to pfkey_spdget
Date: Thu, 8 Mar 2007 12:12:04 -0500 (EST)
Message-ID: <Line.LNX.4.64.0703081159490.9412@d.namei>
References: <1172861484.31047.26.camel@localhost.localdomain>
 <20070307.154316.68038380.davem@davemloft.net>  <20070307.160740.77057241.davem@davemloft.net>
 <1173370815.31047.134.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, vyekkirala@trustedcs.com,
	cxzhang@watson.ibm.com, sds@tycho.nsa.gov
To: Eric Paris <eparis@parisplace.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail2.sea5.speakeasy.net ([69.17.117.4]:43369 "EHLO
	mail2.sea5.speakeasy.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752583AbXCHRMH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 8 Mar 2007 12:12:07 -0500
In-Reply-To: <1173370815.31047.134.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 8 Mar 2007, Eric Paris wrote:

> which didn't have my fix up because i didn't commit it to my local
> branch.  Is there a better way to get a diff between my miller tree and
> 'everything in the branch I have checked out even if it is not
> committed'?

I'd suggest you commit all your changes in local branches, then export 
them as emails via git-format-patch for posting.

Something like:

 davem-upstream         [1]
  +- for-davem          [2]
     +- for-davem-prep  [3]

Do all of your work in [3], so you can manage the queue of patches there 
before merging/applying them into [2] as a final patch series.

So, if one of the commits in [3] needs fixing, you can, for example, 
export commits up to that with git-format-patch, git-reset --hard to the 
broken commit, fix, compile, test then reapply the exported commits.  
Then, once it's all ready, merge into [2] (or export & apply to avoid 
merge commits).

This is just one possible workflow.  There are probably several better.


- James
-- 
James Morris
<jmorris@namei.org>
