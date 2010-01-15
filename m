From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: What protects rcu_dereference() in __in6_dev_get()?
Date: Fri, 15 Jan 2010 16:31:36 +0100
Message-ID: <1263569496.4244.436.camel@laptop>
References: <20100114183215.GA16866@linux.vnet.ibm.com>
	 <4B500217.6070908@gmail.com> <20100115151559.GD6770@linux.vnet.ibm.com>
	 <4B5089CA.2050202@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: paulmck@linux.vnet.ibm.com, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, mingo@elte.hu, akpm@linux-foundation.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:53191 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752774Ab0AOPbt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 10:31:49 -0500
In-Reply-To: <4B5089CA.2050202@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-01-15 at 16:29 +0100, Eric Dumazet wrote:

> I guess so, but is lockdep_is_held(&mutex) actually cheking this mutex is owned by us ?

Yep, assuming lockdep is still functional, otherwise its return value
will be undefined.

