From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Mon, 06 Jun 2011 14:40:26 -0700 (PDT)
Message-ID: <20110606.144026.1544243502220840783.davem@davemloft.net>
References: <20110606.122217.2183968212149987796.davem@davemloft.net>
	<1307390721.8149.2763.camel@tardy>
	<17839.1307394369@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36288 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752500Ab1FFVkf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 17:40:35 -0400
In-Reply-To: <17839.1307394369@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Mon, 06 Jun 2011 14:06:09 -0700

> 	Right, the common use case for balance-rr (round robin) is to
> maximize TCP throughput for one connection, over a set of whatever
> network devices are available (or are cheap) by striping that connection
> across multiple interfaces.  The tcp_reordering sysctl is set to some
> large value so that TCP will deal with the reordering as best it can.

FWIW, I really would never, ever, encourage schemes like this.  Even
if they do happen to work.
