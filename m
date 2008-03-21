From: David Miller <davem@davemloft.net>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
Date: Fri, 21 Mar 2008 00:31:23 -0700 (PDT)
Message-ID: <20080321.003123.180348056.davem@davemloft.net>
References: <20080321061727.491610308@sgi.com>
	<47E35D73.6060703@cosmosbay.com>
	<Pine.LNX.4.64.0803210002450.15903@schroedinger.engr.sgi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: clameter@sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757245AbYCUHb3@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0803210002450.15903@schroedinger.engr.sgi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christoph Lameter <clameter@sgi.com>
Date: Fri, 21 Mar 2008 00:03:51 -0700 (PDT)

> On Fri, 21 Mar 2008, Eric Dumazet wrote:
> 
> > But, isnt it defeating the purpose of this *particular* vmalloc() use ?
> 
> I thought that was controlled by hashdist? I did not see it used here and 
> so I assumed that the RR was not intended here.

It's intended for all of the major networking hash tables.
