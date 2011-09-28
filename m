From: David Miller <davem@redhat.com>
Subject: Re: [patch 1/1] connector: add comm change event report to proc
 connector
Date: Wed, 28 Sep 2011 13:42:07 -0400 (EDT)
Message-ID: <20110928.134207.174306348033999091.davem@redhat.com>
References: <201109211926.p8LJQk0P007038@hpaq6.eem.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vzapolskiy@gmail.com, zbr@ioremap.net
To: akpm@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:20085 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754517Ab1I1Rm0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 13:42:26 -0400
In-Reply-To: <201109211926.p8LJQk0P007038@hpaq6.eem.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: akpm@google.com
Date: Wed, 21 Sep 2011 12:26:44 -0700

> From: Vladimir Zapolskiy <vzapolskiy@gmail.com>
> Subject: connector: add comm change event report to proc connector
> 
> Add an event to monitor comm value changes of tasks.  Such an event
> becomes vital, if someone desires to control threads of a process in
> different manner.
> 
> A natural characteristic of threads is its comm value, and helpfully
> application developers have an opportunity to change it in runtime. 
> Reporting about such events via proc connector allows to fine-grain
> monitoring and control potentials, for instance a process control daemon
> listening to proc connector and following comm value policies can place
> specific threads to assigned cgroup partitions.
> 
> It might be possible to achieve a pale partial one-shot likeness without
> this update, if an application changes comm value of a thread generator
> task beforehand, then a new thread is cloned, and after that proc
> connector listener gets the fork event and reads new thread's comm value
> from procfs stat file, but this change visibly simplifies and extends the
> matter.
> 
> Signed-off-by: Vladimir Zapolskiy <vzapolskiy@gmail.com>
> Acked-by: Evgeniy Polyakov <zbr@ioremap.net>
> Cc: David Miller <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@google.com>

Applied.
