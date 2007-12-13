From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: 2.6.24-rc4-mm1 - BUG in tcp_fragment
Date: Fri, 14 Dec 2007 01:00:08 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712140024360.12376@kivilampi-30.cs.helsinki.fi>
References: <20071204211701.994dfce6.akpm@linux-foundation.org>
 <47616FA6.1010607@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>
To: Cedric Le Goater <clg@fr.ibm.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34699 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933966AbXLMXAN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 18:00:13 -0500
In-Reply-To: <47616FA6.1010607@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 13 Dec 2007, Cedric Le Goater wrote:

> I got this one while compiling on NFS.
> 
> C.
> 
> kernel BUG at /home/legoater/linux/2.6.24-rc4-mm1/include/net/tcp.h:1480!

I'm not exactly sure what patches you have applied and which patches are 
not, with rc4-mm1 there are two patches (first one was incomplete, I 
assume you had at least that one based on your other mail) to really fix 
the issues in (__|)tcp_reset_fack_counts(...). However, there seems to be 
so much breakage that I have a bit trouble to decide where to start...
The situation seems bit scary :-).

So, I might soon prepare a revert patch for most of the questionable 
TCP parts and ask Dave to apply it (and drop them fully during next 
rebase) unless I suddently figure something out soon which explains 
all/most of the problems, then return to drawing board. ...As it seems 
that the cumulative ACK processing problem discovered later on (having 
rather cumbersome solution with skbs only) will make part of the work 
that's currently in net-2.6.25 quite useless/duplicate effort. But thanks 
anyway for reporting these.


-- 
 i.
