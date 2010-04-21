From: David Miller <davem@davemloft.net>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 17:15:25 -0700 (PDT)
Message-ID: <20100420.171525.200010343.davem@davemloft.net>
References: <Pine.LNX.4.64.1004201947470.29017@hs20-bc2-1.build.redhat.com>
	<20100420.170038.130590455.davem@davemloft.net>
	<Pine.LNX.4.64.1004202003010.13651@hs20-bc2-1.build.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net
To: mpatocka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35296
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752152Ab0DUAPT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Apr 2010 20:15:19 -0400
In-Reply-To: <Pine.LNX.4.64.1004202003010.13651@hs20-bc2-1.build.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mikulas Patocka <mpatocka@redhat.com>
Date: Tue, 20 Apr 2010 20:12:45 -0400 (EDT)

> Why is it using GSO on bridging?

Unlike LRO, GRO and GSO are completely valid in bridging and
routing situations.

In fact, in virtualization environments it is essential for
good performance.
