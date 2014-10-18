From: Mathieu Desnoyers <mathieu.desnoyers@efficios.com>
Subject: Re: Queue with wait-free enqueue, blocking dequeue, splice
Date: Sat, 18 Oct 2014 11:48:12 +0000 (UTC)
Message-ID: <412768308.11171.1413632892841.JavaMail.zimbra@efficios.com>
References: <1311316954.11157.1413631325000.JavaMail.zimbra@efficios.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	netdev@vger.kernel.org
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.efficios.com ([78.47.125.74]:54970 "EHLO mail.efficios.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750915AbaJRL5J (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 18 Oct 2014 07:57:09 -0400
In-Reply-To: <1311316954.11157.1413631325000.JavaMail.zimbra@efficios.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesper,

(re-send after getting the right netdev ML address)

Following our LPC discussion on lock-free queue algorithms
for qdisc, here is some info on the wfcqueue implementation
found in Userspace RCU. See http://urcu.so for info and
git repository.

Here is the wfcqueue ported to the Linux kernel I sent last
year as RFC:
https://lkml.org/lkml/2013/3/14/289

I'm very interested to learn if it fits well for your
use-case,

Feedback is welcome,

Thanks!

Mathieu

-- 
Mathieu Desnoyers
EfficiOS Inc.
http://www.efficios.com
