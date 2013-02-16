From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] netpoll: add some missing __rcu marks in
 several places
Date: Sat, 16 Feb 2013 13:33:34 +0800
Message-ID: <1360992814.21612.0.camel@cr0>
References: <20130213223935.122d035b@nehalam.linuxnetplumber.net>
	 <1360831039-11418-1-git-send-email-amwang@redhat.com>
	 <20130214.132054.2237485951582283881.davem@davemloft.net>
	 <1360984587.12539.2.camel@cr0> <1360987823.19353.42.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jiri@resnulli.us, vyasevic@redhat.com, stephen@networkplumber.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:29079 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750853Ab3BPFdr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 16 Feb 2013 00:33:47 -0500
In-Reply-To: <1360987823.19353.42.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-02-15 at 20:10 -0800, Eric Dumazet wrote:
> On Sat, 2013-02-16 at 11:16 +0800, Cong Wang wrote:
> 
> > The reason is we don't dereference ->npinfo pointer, we just check if it
> > is NULL, so doesn't need to call rcu_dereference(). Or am I missing
> > anything?
> 
> Yes you are missing that the right thing to do is to use
> rcu_access_pointer()
> 
> Sparse errors should not be fixed using random RCU verbs,
> please be more careful.

Ah, I wasn't aware of that API. Will send v3.

Thanks!
