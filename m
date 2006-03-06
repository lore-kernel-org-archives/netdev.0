From: "Chris Leech" <chris.leech@gmail.com>
Subject: Re: [PATCH 8/8] [I/OAT] TCP recv offload to I/OAT
Date: Mon, 6 Mar 2006 11:28:39 -0800
Message-ID: <41b516cb0603061128x6af77a79gade442a74e44075c@mail.gmail.com>
References: <20060303214036.11908.10499.stgit@gitlost.site>
	 <20060303214236.11908.98881.stgit@gitlost.site>
	 <20060304231842.GA3103@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932352AbWCFT3A@vger.kernel.org>
To: "Greg KH" <greg@kroah.com>
In-Reply-To: <20060304231842.GA3103@kroah.com>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> #ifdef is not needed here (try not to put #ifdef in .c files.)  I think
> a few of your other usages of #ifdef in this file can also be removed
> with judicious use of inline functions in a .h file.

ACK on all the ifdef comments.  I may have gone a little ifdef crazy
making sure I could get to a zero impact state with these patches
applied but CONFIG_NET_DMA turned off.  I'll get these cleaned up.

- Chris
