From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 11/11] netfilter warning fix
Date: Mon, 5 Feb 2007 18:53:24 -0800
Message-ID: <20070205185324.16b54b64.akpm@linux-foundation.org>
References: <200702060032.l160WErX004652@shell0.pdx.osdl.net>
	<20070205.181026.122835715.davem@davemloft.net>
	<20070205181810.bbfbf42c.akpm@linux-foundation.org>
	<20070205.184408.34759062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@trash.net, dipankar@in.ibm.com,
	paulmck@us.ibm.com, mingo@elte.hu
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:46075 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S964996AbXBFCxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 5 Feb 2007 21:53:43 -0500
In-Reply-To: <20070205.184408.34759062.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 05 Feb 2007 18:44:08 -0800 (PST) David Miller <davem@davemloft.net> wrote:

> I bet this rcu_read_lock()-implies-preempt_disable() assumption has
> spread into other areas of the tree as well.

Me too.  Although one expects that other holes will cause might_sleep or
lockdep warnings pretty easily.

Still, life is hard enough as it is.  I think I'll shelve rcu-preempt
pending resolution of this.

