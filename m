From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: Fix the b0rked ingress VLAN_FLAG_REORDER_HDR
 check.
Date: Tue, 24 May 2011 02:24:06 -0400 (EDT)
Message-ID: <20110524.022406.2228892895515155850.davem@davemloft.net>
References: <m1oc2tyn20.fsf_-_@fess.ebiederm.org>
	<20110524.005414.2103486595611055177.davem@davemloft.net>
	<m1aaectyed.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, greearb@candelatech.com,
	nicolas.2p.debian@gmail.com, jpirko@redhat.com, xiaosuo@gmail.com,
	netdev@vger.kernel.org, kaber@trash.net, fubar@us.ibm.com,
	eric.dumazet@gmail.com, andy@greyhouse.net, jesse@nicira.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:33904 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751697Ab1EXGZf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 02:25:35 -0400
In-Reply-To: <m1aaectyed.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 23 May 2011 23:18:02 -0700

> Feel free to read through the code, to convince yourself it is correct.
> In addition the code is untouched from the vlan header insertion for
> emulation of vlan header acceleration in dev_hard_start_xmit() which
> presumably has been working for quite awhile.

I'm not keeping code there that does eth_hdr(skb)->foo when there
can be either a vlan_hdr(skb) or a eth_hdr(skb) there.

That's just asking for trouble.
