From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: improve mqprio inputs for queue offsets and
 counts
Date: Tue, 26 Apr 2011 15:00:22 -0700
Message-ID: <20110426150022.1cee01be@nehalam>
References: <20110426194441.23726.23489.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43824 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932231Ab1DZWA0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Apr 2011 18:00:26 -0400
In-Reply-To: <20110426194441.23726.23489.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 26 Apr 2011 12:44:42 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> This changes mqprio input format to be more user friendly.
> 
> Old usage,
> 
> # ./tc/tc qdisc add dev eth3 root mqprio help
> Usage: ... mqprio [num_tc NUMBER] [map P0 P1...]
>                   [offset txq0 txq1 ...] [count cnt0 cnt1 ...] [hw 1|0]
> 
> New uage,
> 
> # ./tc/tc qdisc add dev eth3 root mqprio help
> Usage: ... mqprio [num_tc NUMBER] [map P0 P1 ...]
>                   [queues count1@offset1 count2@offset2 ...] [hw 1|0]
> 
> Suggested-by: Ben Hutchings <bhutchings@solarflare.com>
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied (fixed typo in commit message)

-- 
