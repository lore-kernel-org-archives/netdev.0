From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] tcp: fix ABC in tcp_slow_start()
Date: Fri, 20 Jul 2012 11:02:34 -0700 (PDT)
Message-ID: <20120720.110234.810125972347182800.davem@davemloft.net>
References: <wwxik81fhb83pkj3alus6j68.1342807303829@email.android.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, ycheng@google.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, therbert@google.com, shemminger@vyatta.com,
	johnwheffner@gmail.com, nanditad@google.com
To: stephen.hemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54284 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752795Ab2GTSCf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 14:02:35 -0400
In-Reply-To: <wwxik81fhb83pkj3alus6j68.1342807303829@email.android.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Date: Fri, 20 Jul 2012 11:01:43 -0700

> TCP ABC was an experiment that failed. It solves a problem that does
> not exist on Linux. I did the implementation mostly to prove that.
> 
> Perhaps it abc should just be removed?

This is my impression as well.
