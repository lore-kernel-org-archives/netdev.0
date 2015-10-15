From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netfilter: ipset: Fix sleeping memory allocation in
 atomic context
Date: Thu, 15 Oct 2015 11:46:58 -0700
Message-ID: <1444934818.25595.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1444906569-9131-1-git-send-email-kernel@kyup.com>
	 <1444915978.4200.4.camel@edumazet-glaptop2.roam.corp.google.com>
	 <561FAD24.4050708@kyup.com>
	 <1444919523.4200.16.camel@edumazet-glaptop2.roam.corp.google.com>
	 <alpine.DEB.2.10.1510152015370.12052@blackhole.kfki.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nikolay Borisov <kernel@kyup.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	operations@siteground.com
To: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.10.1510152015370.12052@blackhole.kfki.hu>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2015-10-15 at 20:25 +0200, Jozsef Kadlecsik wrote:

> Nikolay answered this pretty well: we wouldn't need the spinlock at all, 
> because all commands are serialized anyway with the netlink mutex. But the 
> garbage collector is called by a timer and therefore spinlock is used.
> 

Good, please Nikolay, send a v2 of the patch with all these details
explained in the changelog, so that we can all agree.

If properly explained, no need to add the stack trace which does not
really tell us the story.

Thanks !



