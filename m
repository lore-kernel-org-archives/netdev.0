From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next v2] tcp: Add RFC4898
 tcpEStatsPerfDataSegsOut/In
Date: Tue, 08 Mar 2016 15:24:44 -0500 (EST)
Message-ID: <20160308.152444.555296214200726963.davem@davemloft.net>
References: <1457402465-1736429-1-git-send-email-kafai@fb.com>
	<20160308194153.GN31728@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, netdev@vger.kernel.org, kernel-team@fb.com,
	rapier@psc.edu, edumazet@google.com, ncardwell@google.com,
	ycheng@google.com
To: mleitner@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44373 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750954AbcCHUYs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2016 15:24:48 -0500
In-Reply-To: <20160308194153.GN31728@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcelo Ricardo Leitner <mleitner@redhat.com>
Date: Tue, 8 Mar 2016 16:41:54 -0300

> On Mon, Mar 07, 2016 at 06:01:05PM -0800, Martin KaFai Lau wrote:
>> v2:
>> Rework based on recent fix by Eric:
>> commit a9d99ce28ed3 ("tcp: fix tcpi_segs_in after connection establishment")
>> 
>> v1:
> 
> Patch itself looks good to me, just this patch history is better placed
> on the Notes region (together with the diffstat) or place a scissors
> mark, otherwise it will be present in the git changelog too.

I like seeing it in the commit message.

Then later people can figure out answers to questions like "why didn't you
implement this like X" and see in the version history that this was
attempted first and then intentionally changed.

I even move version history into the commit message when people try to
move it out, so please don't do that.

This is important _especially_ for "0/N" header postings for a patch
series.

DO NOT LOSE INFORMATION.
