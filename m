From: David Miller <davem@davemloft.net>
Subject: Re: net/netfilter/nf_conntrack_proto_tcp.c:1606:9: error:
 =?iso-8859-7?B?oXN0cnVjdCBuZl9wcm90b19uZXSi?= has no member named
 =?iso-8859-7?B?oXVzZXKi?=
Date: Mon, 11 Jun 2012 18:34:54 -0700 (PDT)
Message-ID: <20120611.183454.1290469931190793239.davem@davemloft.net>
References: <20120611221521.GA27239@1984>
	<20120611.152344.1072167705198124284.davem@davemloft.net>
	<20120612002655.GA28155@1984>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: wfg@linux.intel.com, gaofeng@cn.fujitsu.com, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47508 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752913Ab2FLBez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jun 2012 21:34:55 -0400
In-Reply-To: <20120612002655.GA28155@1984>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Tue, 12 Jun 2012 02:26:55 +0200

> Would you be OK if I send you patches to move all sysctl part of
> nf_conntrack_proto_*.c to nf_conntrack_proto_*_sysctl.c
> 
> I can also do the same for nf_conntrack_proto.c.
> 
> This means more files under the net/netfilter directory, but less
> ifdef kludges in the code.
> 
> Please, have a look at the patch enclosed to this email in case you
> want to see how it would look like in the end with my proposal.

Looks good to me.

But I have to ask, why are you able to now unconditionally use
pn->users vs. pn->ctl_table in those tests?
