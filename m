From: Christoph Lameter <clameter@sgi.com>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
Date: Fri, 21 Mar 2008 00:03:51 -0700 (PDT)
Message-ID: <Pine.LNX.4.64.0803210002450.15903@schroedinger.engr.sgi.com>
References: <20080321061703.921169367@sgi.com> <20080321061727.491610308@sgi.com>
 <47E35D73.6060703@cosmosbay.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755901AbYCUHFd@vger.kernel.org>
In-Reply-To: <47E35D73.6060703@cosmosbay.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 21 Mar 2008, Eric Dumazet wrote:

> But, isnt it defeating the purpose of this *particular* vmalloc() use ?

I thought that was controlled by hashdist? I did not see it used here and 
so I assumed that the RR was not intended here.
