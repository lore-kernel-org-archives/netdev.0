From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: wireless-drivers-next 2016-05-13 (take two)
Date: Fri, 20 May 2016 19:41:48 -0400 (EDT)
Message-ID: <20160520.194148.1467687685270353684.davem@davemloft.net>
References: <87eg8yfc8b.fsf@kamboji.qca.qualcomm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kvalo@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53481 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbcETXlu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 May 2016 19:41:50 -0400
In-Reply-To: <87eg8yfc8b.fsf@kamboji.qca.qualcomm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Kalle Valo <kvalo@codeaurora.org>
Date: Thu, 19 May 2016 15:45:08 +0300

> this the second version of the last pull request to net-next for 4.7,
> which got postponed due to the recent iwlwifi merge conflict. Now that
> Linus fixed the merge problem in his tree I actually didn't have to fix
> anything in my tree anymore. So that's why I still use the same tag as
> in my previous pull request.
> 
> The only dependency is that you need Linus' iwlwifi fix in your tree
> before you pull this:
> 
> 0e034f5c4bc4 iwlwifi: fix mis-merge that breaks the driver
> 
> So if you could pull latest Linus' tree to net-next that would solve
> that. I just did a test merge of that on your net-next tree and didn't
> see any conflicts, so this pull should go smoothly. Also these patches
> have been in linux-next at least a week now. But please let me know if
> you see any issues.

Done, pulled, thanks a lot!

> And I think a lesson learned from this is that I need to immediately
> merge wireless-drivers to wireless-drivers-next if there are any
> conflicts between the trees. Or how do you suggest to handle cases like
> that?

You shouldn't have to worry about this kind of stuff at all, and let's
just hope I handle the conflict better next time. :-)
