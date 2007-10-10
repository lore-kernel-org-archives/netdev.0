From: Roland Dreier <rdreier@cisco.com>
Subject: Re: [PATCH] IB/ipoib: Bound the net device to the ipoib_neigh structue
Date: Wed, 10 Oct 2007 11:31:30 -0700
Message-ID: <aday7eaddod.fsf@cisco.com>
References: <11916151232222-git-send-email-fubar@us.ibm.com>
	<470C200D.4010705@pobox.com> <470C2343.1020800@garzik.org>
	<20071009.181246.41634534.davem@davemloft.net> <706.1191979132@death>
	<470CF7E1.6060503@voltaire.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jay Vosburgh <fubar@us.ibm.com>, jeff@garzik.org,
	David Miller <davem@davemloft.net>, ogerlitz@voltaire.com,
	netdev@vger.kernel.org
To: Moni Shoua <monis@voltaire.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sj-iport-2-in.cisco.com ([171.71.176.71]:47884 "EHLO
	sj-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752111AbXJJSbh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Oct 2007 14:31:37 -0400
In-Reply-To: <470CF7E1.6060503@voltaire.com> (Moni Shoua's message of "Wed, 10 Oct 2007 18:03:45 +0200")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

 > I also ran a test for the code in the branch of 2.6.24 and found a problem.
 > I see that ifconfig down doesn't return (for IPoIB interfaces) and it's stuck in napi_disable() in the kernel (any idea why?)

For what it's worth, I took the upstream 2.6.23 git tree and merged in
Dave's latest net-2.6.24 tree and my latest for-2.6.24 tree and tried
that.  I brought up an IPoIB interface, sent a few pings, and did
ifconfig down, and it worked fine.

Can you try the same thing without the bonding patches to see if your
setup works OK too?

Also can you give more details about what you do to get ifconfig down stuck?

 - R.
