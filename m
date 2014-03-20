From: David Miller <davem@davemloft.net>
Subject: Re: [net-next 13/15] ixgbe: clean up
 ixgbe_atr_compute_perfect_hash_82599
Date: Thu, 20 Mar 2014 14:20:33 -0400 (EDT)
Message-ID: <20140320.142033.306107166278366828.davem@davemloft.net>
References: <1395304385-6874-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1395304385-6874-14-git-send-email-jeffrey.t.kirsher@intel.com>
	<063D6719AE5E284EB5DD2968C1650D6D0F6E224D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jeffrey.t.kirsher@intel.com, jacob.e.keller@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, sassmann@redhat.com,
	asharma@fb.com
To: David.Laight@ACULAB.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50189 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933099AbaCTSUg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2014 14:20:36 -0400
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D0F6E224D@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Laight <David.Laight@ACULAB.COM>
Date: Thu, 20 Mar 2014 09:44:58 +0000

> From: Jeff Kirsher
>> From: Jacob Keller <jacob.e.keller@intel.com>
>> 
>> Rather than assign several parameters in a row, we should use a for
>> loop, which reduces code size.
> 
> And probably increases execution time.
> Especially for the first two blocks.

This is not a fast path, so code size is more important than execution
time here.
