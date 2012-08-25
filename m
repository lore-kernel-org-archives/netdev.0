From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] iproute2: Add FDB print and update cmds for self and
 master
Date: Fri, 24 Aug 2012 17:11:35 -0700
Message-ID: <20120824171135.2258065e@nehalam.linuxnetplumber.net>
References: <20120823203719.6544.22863.stgit@jf-dev1-dcblab>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vyasevic@redhat.com
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:55727 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756868Ab2HYALx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 24 Aug 2012 20:11:53 -0400
In-Reply-To: <20120823203719.6544.22863.stgit@jf-dev1-dcblab>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 23 Aug 2012 13:37:19 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> Add command to update and print FDB entries with NTF_SELF and
> NTF_MASTER set.
> 
> Example usages illustrating use of 'self' to program embedded
> forwarding table and 'master' to configure the forwarding table
> of the bridge. Also shows 'master self' used to update both in
> the same command.
> 
> #./br/br fdb add 00:1b:21:55:23:60 dev eth3 self
> #./br/br fdb add 00:1b:21:55:23:60 dev eth3 master
> #./br/br fdb add 00:1b:21:55:23:61 dev eth3 self master
> #./br/br fdb add 00:1b:21:55:23:62 dev eth3
> #./br/br fdb show
> eth3    00:1b:21:55:23:60       local self
> eth3    00:1b:21:55:23:61       local self
> eth3    33:33:00:00:00:01       local self
> eth3    01:00:5e:00:00:01       local self
> eth3    33:33:ff:55:23:59       local self
> eth3    01:00:5e:00:00:fb       local self
> eth33   33:33:00:00:00:01       local self
> eth34   33:33:00:00:00:01       local self
> eth3    00:1b:21:55:23:59       local master
> eth3    00:1b:21:55:23:60       static master
> eth3    00:1b:21:55:23:62       static master
> eth3    00:1b:21:55:23:61       static master
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied
