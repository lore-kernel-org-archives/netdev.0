From: Andrew Morton <akpm@osdl.org>
Subject: Re: [patch 3/4] net: Percpufy frequently used variables --
 proto.sockets_allocated
Date: Fri, 27 Jan 2006 15:08:47 -0800
Message-ID: <20060127150847.48c312c0.akpm@osdl.org>
References: <20060126185649.GB3651@localhost.localdomain>
	<20060126190357.GE3651@localhost.localdomain>
	<43D9DFA1.9070802@cosmosbay.com>
	<20060127195227.GA3565@localhost.localdomain>
	<20060127121602.18bc3f25.akpm@osdl.org>
	<20060127224433.GB3565@localhost.localdomain>
	<20060127150106.38b9e041.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1422660AbWA0XHF@vger.kernel.org>
To: kiran@scalex86.org, dada1@cosmosbay.com, davem@davemloft.net,
	linux-kernel@vger.kernel.org, shai@scalex86.org,
	netdev@vger.kernel.org, pravins@calsoftinc.com
In-Reply-To: <20060127150106.38b9e041.akpm@osdl.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Morton <akpm@osdl.org> wrote:
>
> Oh, and because vm_acct_memory() is counting a singleton object, it can use
> DEFINE_PER_CPU rather than alloc_percpu(), so it saves on a bit of kmalloc
> overhead.

Actually, I don't think that's true.  we're allocating a sizeof(long) with
kmalloc_node() so there shouldn't be memory wastage.
