From: Dan Aloni <da-x@monatomic.org>
Subject: workaround large MTU and N-order allocation failures
Date: Sun, 18 Sep 2005 17:35:26 +0300
Message-ID: <20050918143526.GA24181@localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nick Piggin <nickpiggin@yahoo.com.au>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932092AbVIROcV@vger.kernel.org>
To: Linux Kernel List <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Is there currently a workaround available for handling large MTU 
(larger than 1 page, even 2-order) in the Linux network stack?

The problem with large MTU is external memory fragmentation in
the buddy system following high workload, causing alloc_skb() to 
fail.

I'm interested in patches for both 2.4 and 2.6 kernels.

Thanks,

-- 
Dan Aloni
da-x@monatomic.org, da-x@colinux.org, da-x@gmx.net
