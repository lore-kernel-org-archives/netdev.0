From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH net-next 0/9] inet: frag: cleanup and update
Date: Mon, 28 Jul 2014 10:00:49 +0200
Message-ID: <20140728080049.GC28720@breakpoint.cc>
References: <1406213437-6155-1-git-send-email-nikolay@redhat.com>
 <20140727.223718.1055588669834128686.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: nikolay@redhat.com, netdev@vger.kernel.org, fw@strlen.de,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, alex.aring@gmail.com, eric.dumazet@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:41900 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751070AbaG1IA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2014 04:00:58 -0400
Content-Disposition: inline
In-Reply-To: <20140727.223718.1055588669834128686.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Nikolay Aleksandrov <nikolay@redhat.com>
> Date: Thu, 24 Jul 2014 16:50:28 +0200
> 
> > The end goal of this patchset is to remove the LRU list and to move the
> > frag eviction to a work queue. It also does a couple of necessary cleanups
> > and fixes. Brief patch descriptions:
> 
> Ok I decided to apply this series.
> 
> Honestly I thought the frag counter would be useful for diagnosing problems
> ("are there a lot of frag queues bunched up on my machine?").  But whatever.
> 
> You could make it accurate again by just scanning the hash table really
> quickly and counting how many entries you see, if you wanted to.

Right.  In case someone reports a bug vs. "bogus frag counter" either
myself or Nik will submit a patch to do this.

Thanks David.
