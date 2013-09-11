From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH nf] netfilter: use RCU safe kfree for conntrack
 extensions
Date: Wed, 11 Sep 2013 10:54:38 -0700
Message-ID: <1378922078.21474.5.camel@edumazet-glaptop>
References: <20130911090900.0129AE8AFF@unicorn.suse.cz>
	 <20130911145715.GA2882@linuxace.com>
	 <20130911152804.GA5397@unicorn.suse.cz>
	 <20130911170946.GA2926@linuxace.com>
	 <20130911174248.GA8318@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Phil Oester <kernel@linuxace.com>, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org, Pablo Neira Ayuso <pablo@netfilter.org>,
	Patrick McHardy <kaber@trash.net>,
	Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f43.google.com ([209.85.213.43]:33350 "EHLO
	mail-yh0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755481Ab3IKRyp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Sep 2013 13:54:45 -0400
In-Reply-To: <20130911174248.GA8318@unicorn.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-09-11 at 19:42 +0200, Michal Kubecek wrote:

> Yes, the patch submitted here is against current nf branch. For
> SLES 11 SP1 (with 2.6.32 kernel), I'm going to use call_rcu() the way
> original commit 68b80f11 does. 

Well, please just submit a patch for current tree, using kfree_rcu()

When doing backport to stable branches, needed adaptation shall be done.
