From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2/2] add rcu_assign_index() if ever needed
Date: Wed, 13 Feb 2008 19:41:35 -0800
Message-ID: <20080213194135.c8a88f8c.akpm@linux-foundation.org>
References: <20080213220024.GA30729@linux.vnet.ibm.com>
	<20080213220515.GA10642@linux.vnet.ibm.com>
	<20080214033209.GA7266@in.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	linux-kernel@vger.kernel.org, shemminger@vyatta.com,
	davem@davemloft.net, netdev@vger.kernel.org, dipankar@in.ibm.com,
	herbert@gondor.apana.org.au
To: ego@in.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:41087 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755485AbYBNDmg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Feb 2008 22:42:36 -0500
In-Reply-To: <20080214033209.GA7266@in.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 14 Feb 2008 09:02:09 +0530 Gautham R Shenoy <ego@in.ibm.com> wrote:

> >  /**
> > + * rcu_assign_index - assign (publicize) a index of a newly
> > + * initialized array elementg that will be dereferenced by RCU
> 			^^^^^^^^ 
> 
> I hope Andrew got that one while porting against the latest -mm :)

I don't actually read the comments - I just like to make sure they're
there ;)
