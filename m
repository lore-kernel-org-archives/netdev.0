From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4 V2] Ethernet drivers in 3.14-rc3 kernel: fix 3
 buffer overflows triggered by hardware devices
Date: Tue, 25 Mar 2014 18:17:47 -0400 (EDT)
Message-ID: <20140325.181747.349822123221402039.davem@davemloft.net>
References: <063D6719AE5E284EB5DD2968C1650D6D0F6E8463@AcuExch.aculab.com>
	<CAP6odjh5qgh2dcURHrQ6ERn6a4TfCgBXPm3eJmw2ZsAKyzEzvQ@mail.gmail.com>
	<1395768381.12610.162.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: grantgrundler@gmail.com, David.Laight@aculab.com,
	alon@privatecore.com, ben@decadent.org.uk, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:60255 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751510AbaCYWRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Mar 2014 18:17:49 -0400
In-Reply-To: <1395768381.12610.162.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 25 Mar 2014 10:26:21 -0700

> Some hardware have some flaws, not because its malicious but plainly
> buggy, and its reasonable to take some basic checks on common 'mistakes'
> 
> Checking that the NIC doesn't pretend to receive a bigger frame than the
> expected maximum seems reasonable.

That's awesome when we know that the chip in fact has such an errata.
