From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 3/3] qlge: Increase default TX/RX ring size to
 1024.
Date: Thu, 11 Jun 2009 16:50:14 -0700 (PDT)
Message-ID: <20090611.165014.235867783.davem@davemloft.net>
References: <1244684975-10211-3-git-send-email-ron.mercer@qlogic.com>
	<20090611.022713.35602614.davem@davemloft.net>
	<20090611232159.GA13392@linux-ox1b.qlogic.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44503
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754825AbZFKXuM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jun 2009 19:50:12 -0400
In-Reply-To: <20090611232159.GA13392@linux-ox1b.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Thu, 11 Jun 2009 16:21:59 -0700

>> This is huge.  Even other aggressive NICs such as BNX2X only use 256
>> ring entries per TX queue.
>> 
>> There is a point where increasing definitely hurts, because you're
>> increasing the resident set size of the cpu, as more and more SKBs are
>> effectively "in flight" at a given time and only due to the amount
>> you're allowing to get queued up into the chip.
>> 
>> And with multiqueue, per-queue TX queue sizes should matter less at
>> least to some extent.
>> 
>> Are you sure that jacking the value up this high has no negative side
>> effects for various workloads?
> 
> Just drop this patch for now.  I looked at our spreadsheet and ran the
> tests again and we see a (marginal) throughput increase that leveled off
> at TXQ length of 1024.  In light of yours and Stephens comments I prefer
> to revisit this issue.

Ok, thanks.
