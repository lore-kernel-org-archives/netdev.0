From: Christoph Lameter <clameter@engr.sgi.com>
Subject: Re: [PATCH 0/3] netfilter : 3 patches to boost ip_tables performance
Date: Thu, 22 Sep 2005 08:55:05 -0700 (PDT)
Message-ID: <Pine.LNX.4.62.0509220853070.16871@schroedinger.engr.sgi.com>
References: <43308324.70403@cosmosbay.com> <200509221454.22923.ak@suse.de>
 <20050922125849.GA27413@infradead.org> <200509221505.05395.ak@suse.de>
 <Pine.LNX.4.62.0509220835310.16793@schroedinger.engr.sgi.com>
 <4332D2D9.7090802@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Andi Kleen <ak@suse.de>, Christoph Hellwig <hch@infradead.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030423AbVIVPzd@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <4332D2D9.7090802@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 22 Sep 2005, Eric Dumazet wrote:

> vmalloc_node() should be seldom used, at driver init, or when a new ip_tables
> is loaded. If it happens to be a performance problem, then we can optimize it.

Allright. However, there are a couple of uses of vmalloc_node that I can 
see right now and they will likely increase in the future.

> Why should we spend days of work for a function that is yet to be used ?

I already did a vmalloc_node patch. So no need for spending days of work. 
The patch can wait until it becomes performance critical.
