From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 00/10] tipc: last batch from the sourceforge
 queue
Date: Mon, 30 Apr 2012 21:45:06 -0400 (EDT)
Message-ID: <20120430.214506.837284274083120278.davem@davemloft.net>
References: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	jon.maloy@ericsson.com, erik.hugne@ericsson.com,
	ying.xue@windriver.com
To: paul.gortmaker@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44840 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757312Ab2EABpQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Apr 2012 21:45:16 -0400
In-Reply-To: <1335825428-16053-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Gortmaker <paul.gortmaker@windriver.com>
Date: Mon, 30 Apr 2012 18:36:58 -0400

> I'm glad to say this represents the last batch of salvaged commits
> from what was the sourceforge queue of stuff misplaced on the older
> v2.6.19/v1.7.x baseline.  Going forward, folks got a clear message
> that they _must_ put forward any new/prospective changes on netdev
> for peer review and ask for continuous integration and not stockpile
> crap in a corner (cause I'm sure as hell not going to volunteer to
> be Winston Wolf for it again).
> 
> Anyway, knowing that there isn't any more "old" patches from that to
> worry about, I took the opportunity to close out by clobbering a bunch
> of needless extra blank lines following comments, since there isn't
> any pending patch context fallout to worry about.  This one cosmetic
> change alone makes up most of the diffstat, giving:
> 
>  32 files changed, 16 insertions(+), 530 deletions(-)
> 
> out of the total:
> 
>  34 files changed, 58 insertions(+), 567 deletions(-)

You must feel like you've just moved a mountain, Mr. Wolf.

> That aside, the meat of what is here is:
> 
>   -reduce some of the build up/tear down on configuration paths
> 
>   -more strict checks on published names and payload types
> 
>   -factor out some duplicated code;  +some redundant code deletion.
> 
> Testing has been the usual 64 <---> 32bit using tipc-utils ptts.
> 
> I still want to look at your suggestion of reusing existing code
> for the logging stuff someday, now that the queue is closed out,
> but that is completely separate from the backlog, and it probably
> isn't going to be happening in the 3.5 timeframe.

Pulled, thanks.
