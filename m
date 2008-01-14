From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch for 2.6.24? 1/1] bonding: locking fix
Date: Mon, 14 Jan 2008 15:01:13 -0800
Message-ID: <16796.1200351673@death>
References: <200801140904.m0E94vJd020425@imap1.linux-foundation.org> <Pine.LNX.4.64.0801142313350.26034@bizon.gios.gov.pl> <20080114144754.29a448ad.akpm@linux-foundation.org>
Cc: Krzysztof Oledzki <olel@ans.pl>, davem@davemloft.net,
	jeff@garzik.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e5.ny.us.ibm.com ([32.97.182.145]:47314 "EHLO e5.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750903AbYANXBR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Jan 2008 18:01:17 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e5.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0EN1Gl4000794
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 18:01:16 -0500
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0EN1GLi065814
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 18:01:16 -0500
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0EN1Fah012766
	for <netdev@vger.kernel.org>; Mon, 14 Jan 2008 18:01:16 -0500
In-reply-to: <20080114144754.29a448ad.akpm@linux-foundation.org> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrew Morton <akpm@linux-foundation.org> wrote:
[...]
>That's bond_lock.
>
>This patch (below) addresses what appears to me to be an obvious
>imbalance in rtnl_lock.
>
>I don't care how it's fixed, really.  Someone please fix it?

	I posted a correct patch for this a few days ago:

http://marc.info/?l=linux-netdev&m=119975746803886&w=2

	The correct fix requires more than simply removing the rtnl calls.

	I've got a few other patches in the pipeline, so I'm planning to
repost the set the above patch was a part of plus a few others, most
likely tomorrow.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
