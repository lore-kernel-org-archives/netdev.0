From: David Miller <davem@davemloft.net>
Subject: kbench_mod
Date: Tue, 08 Mar 2011 14:10:09 -0800 (PST)
Message-ID: <20110308.141009.226766666.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36622
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751261Ab1CHWJc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Mar 2011 17:09:32 -0500
Received: from localhost (localhost [127.0.0.1])
	by sunset.davemloft.net (Postfix) with ESMTP id 9243E24C089
	for <netdev@vger.kernel.org>; Tue,  8 Mar 2011 14:10:09 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I just added a special kernel module to the net_test_tools tree,
it allows more accurate measurement of routing lookups.

It does cycle counts across one routing lookup.

The flow key is controlled by module parameters, iif != 0 means
input route lookup, otherwise we do an output lookup.

What's cool is you can jack-up the warmup_count value and then
run insmod under "perf record" and it just works.
