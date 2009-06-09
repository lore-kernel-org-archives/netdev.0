From: "=?ISO-8859-15?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: behavior of TSO in kernel
Date: Tue, 9 Jun 2009 11:01:55 +0300 (EEST)
Message-ID: <Pine.LNX.4.64.0906091052080.31791@melkinkari.cs.Helsinki.FI>
References: <340578.72366.qm@web94815.mail.in2.yahoo.com>
 <20090605.182038.133831345.davem@davemloft.net> <171835.76446.qm@web94811.mail.in2.yahoo.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Radha Mohan <radhamohan_ch@yahoo.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:46463 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755442AbZFIIBx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Jun 2009 04:01:53 -0400
In-Reply-To: <171835.76446.qm@web94811.mail.in2.yahoo.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 6 Jun 2009, Radha Mohan wrote:

> >The TSO engine of the networking has been rewritten at least
> >3 times since 2.6.15
> Thank you for the info.
> Actually we are working on an SoC and we just started moving from kernel 
> 2.6.15, so can you tell me from which kernel version the latest TSO 
> engine is being used. That'll make our life easier and avoid moving 
> kernels frequently. Currently we are thinking of moving to 2.6.24. Will 
> that do??   

There are at least some fixes since that time too... Besides, I'd 
recommend you staying away from 2.6.24 anyway because it is rather
broken on TCP side too (and was already obsolete when the problem was 
discovered so it was never fixed)...

What is the problem in starting with a very recent kernel such as the 
almost released 2.6.30 or the current stable 2.6.29? Another alternative 
you might want to consider the long supported version 2.6.27 (IIRC, check 
the archives whether it was .27 or .28). However, if there's even 
a slightest consideration of submitting your changes into mainline, the
latest is the best choice, and keeping up with the upstream during the 
development is certainly my recommendation too (with git it should be 
rather straightforward to handle that).


-- 
 i.
