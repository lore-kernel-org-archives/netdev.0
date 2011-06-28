From: <Shyam_Iyer@Dell.com>
Subject: RE: [PATCH] [net][bna] Fix call trace when interrupts are disabled
 while sleeping function kzalloc is called
Date: Tue, 28 Jun 2011 11:48:26 -0700
Message-ID: <DBFB1B45AF80394ABD1C807E9F28D1570453626FF2@BLRX7MCDC203.AMER.DELL.COM>
References: <1309206092-23064-1-git-send-email-shyam_iyer@dell.com>
 <20110627.160706.1453191829412045606.davem@davemloft.net>
 <DBFB1B45AF80394ABD1C807E9F28D1570453626FF0@BLRX7MCDC203.AMER.DELL.COM>
 <E5313AF6F2BFD14293E5FD0F94750F86A82D66F5E5@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <ddutt@Brocade.COM>, <huangj@Brocade.COM>
To: <rmody@brocade.com>, <davem@davemloft.net>,
	<shyam.iyer.t@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:62697 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759070Ab1F1Ssb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 14:48:31 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A82D66F5E5@HQ1-EXCH01.corp.brocade.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Rasesh Mody [mailto:rmody@brocade.com]
> Sent: Tuesday, June 28, 2011 1:28 PM
> To: Iyer, Shyam; davem@davemloft.net; shyam.iyer.t@gmail.com
> Cc: netdev@vger.kernel.org; Debashis Dutt; Jing Huang
> Subject: RE: [PATCH] [net][bna] Fix call trace when interrupts are
> disabled while sleeping function kzalloc is called
> 
> >From: Shyam_Iyer@Dell.com [mailto:Shyam_Iyer@Dell.com]
> >Sent: Tuesday, June 28, 2011 9:30 AM
> >
> >Here is try 2.
> >
> >I found that I had to initialize the flags variable outside the
> >spin_lock_irqsave in the following way to fix the problem. The
> sleeping
> >kzalloc function is in fact in the request_threaded_irq call which
> >allocates the irq handler function and its flags arguments.
> >
> >Attached patch fixes the issue.
> 
> The attached patch may fix the issue in MSIX mode, however we'll
> continue to see the issue in INTX mode. Using a separate irq_flags may
> be a good idea.

You are right.. Resending another version.
-Shyam
