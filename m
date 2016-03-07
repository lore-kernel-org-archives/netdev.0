From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/4] vxlan: Enforce IP ID verification on
 outer headers
Date: Mon, 07 Mar 2016 14:09:47 -0500 (EST)
Message-ID: <20160307.140947.1831226984496616218.davem@davemloft.net>
References: <20160307172201.5295.69740.stgit@localhost.localdomain>
	<20160307172214.5295.52624.stgit@localhost.localdomain>
	<CAJ3xEMgpiaaLJrSqefOgrDVXsyKDtqSYQ7O01jq_UYp+UeT4bg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: aduyck@mirantis.com, netdev@vger.kernel.org
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930AbcCGTJt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 14:09:49 -0500
In-Reply-To: <CAJ3xEMgpiaaLJrSqefOgrDVXsyKDtqSYQ7O01jq_UYp+UeT4bg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Mon, 7 Mar 2016 20:05:20 +0200

> On Mon, Mar 7, 2016 at 7:22 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>> This change enforces the IP ID verification on outer headers.  As a result
>> if the DF flag is not set on the outer header we will force the flow to be
>> flushed in the event that the IP ID is out of sequence with the existing
>> flow.
> 
> Can you please state the precise requirement for aggregation w.r.t IP
> IDs here? and point to where/how this is enforced, e.g for
> non-tunneled TCP GRO-ing?

I also didn't see a nice "PATCH 0/4" posting explaining this series and
I'd really like to see that.
