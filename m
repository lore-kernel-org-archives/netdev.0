From: Nick Piggin <nickpiggin@yahoo.com.au>
Subject: Re: workaround large MTU and N-order allocation failures
Date: Mon, 19 Sep 2005 16:31:02 +1000
Message-ID: <1127111462.5272.7.camel@npiggin-nld.site>
References: <20050918143526.GA24181@localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932334AbVISGbR@vger.kernel.org>
To: Dan Aloni <da-x@monatomic.org>
In-Reply-To: <20050918143526.GA24181@localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2005-09-18 at 17:35 +0300, Dan Aloni wrote:
> Hello,
> 
> Is there currently a workaround available for handling large MTU 
> (larger than 1 page, even 2-order) in the Linux network stack?
> 
> The problem with large MTU is external memory fragmentation in
> the buddy system following high workload, causing alloc_skb() to 
> fail.
> 
> I'm interested in patches for both 2.4 and 2.6 kernels.
> 

Yes there is currently a workaround. That is to keep increasing
/proc/sys/vm/min_free_kbytes until your allocation failures stop.

Nick

-- 
SUSE Labs, Novell Inc.



Send instant messages to your online friends http://au.messenger.yahoo.com 
