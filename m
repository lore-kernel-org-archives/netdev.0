From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Thu, 05 Nov 2009 21:08:10 -0800 (PST)
Message-ID: <20091105.210810.124818005.davem@davemloft.net>
References: <20091002141407.30224.54207.stgit@dev.haskins.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ghaskins@novell.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752138AbZKFFHt@vger.kernel.org>
In-Reply-To: <20091002141407.30224.54207.stgit@dev.haskins.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gregory Haskins <ghaskins@novell.com>
Date: Fri, 02 Oct 2009 10:20:00 -0400

> The following is an RFC for an attempt at addressing a zero-copy solution.
> 
> To be perfectly honest, I have no idea if this is the best solution, or if
> there is truly a problem with skb->destructor that requires an alternate
> mechanism.  What I do know is that this patch seems to work, and I would
> like to see some kind of solution available upstream.  So I thought I would
> send my hack out as at least a point of discussion.  FWIW: This has been
> tested heavily in my rig and is technically suitable for inclusion after
> review as is, if that is decided to be the optimal path forward here.
> 
> Thanks for your review and consideration,

I have no fundamental objections, but when you submit this for
real can you show the code that uses it so we can get a better
idea about things?

Thanks.
