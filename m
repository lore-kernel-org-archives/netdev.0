From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Fix the b0rked ingress VLAN_FLAG_REORDER_HDR
 check.
Date: Wed, 01 Jun 2011 20:59:40 -0700 (PDT)
Message-ID: <20110601.205940.1179055860757569997.davem@davemloft.net>
References: <m1aaectyed.fsf@fess.ebiederm.org>
	<20110524.022406.2228892895515155850.davem@davemloft.net>
	<m1oc2spmyt.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:46940 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750951Ab1FBEBS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Jun 2011 00:01:18 -0400
In-Reply-To: <m1oc2spmyt.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Tue, 24 May 2011 00:38:34 -0700

> Would you be happier if the pkt_type check was moved earlier in the
> function like say:

Yes, I like this best because it's fully consistent and it fixes
the bug.
