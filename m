From: <Shyam_Iyer@Dell.com>
Subject: RE: [PATCH] [net][bna] Fix call trace when interrupts are disabled
 while sleeping function  kzalloc is called
Date: Tue, 28 Jun 2011 09:32:56 -0700
Message-ID: <DBFB1B45AF80394ABD1C807E9F28D1570453626FF1@BLRX7MCDC203.AMER.DELL.COM>
References: <1309206092-23064-1-git-send-email-shyam_iyer@dell.com>
 <E5313AF6F2BFD14293E5FD0F94750F86A82D66F4FF@HQ1-EXCH01.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <ddutt@brocade.com>, <huangj@Brocade.COM>
To: <rmody@brocade.com>, <shyam.iyer.t@gmail.com>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60ps301.us.dell.com ([143.166.148.206]:38691 "EHLO
	ausc60ps301.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754116Ab1F1QeZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Jun 2011 12:34:25 -0400
In-Reply-To: <E5313AF6F2BFD14293E5FD0F94750F86A82D66F4FF@HQ1-EXCH01.corp.brocade.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Resending the reply for this as well.)

> -----Original Message-----
> From: Rasesh Mody [mailto:rmody@brocade.com]
> Sent: Monday, June 27, 2011 8:51 PM
> To: Shyam Iyer; netdev@vger.kernel.org
> Cc: ddutt@brocadel.com; Iyer, Shyam; Jing Huang
> Subject: RE: [PATCH] [net][bna] Fix call trace when interrupts are
> disabled while sleeping function kzalloc is called
> 
> 
> >From: Shyam Iyer [mailto:shyam.iyer.t@gmail.com]
> >Sent: Monday, June 27, 2011 1:22 PM
> >Subject: [PATCH] [net][bna] Fix call trace when interrupts are
> disabled
> >while sleeping function kzalloc is called
> >
> >The kzalloc sleeps and disabling interrupts(spin_lock_irqsave) causes
> >oops like the one.
> 
> Hi Shyam,
> 
> We are not calling any sleeping function while holding the lock in
> bnad_mbox_irq_alloc(). How would your patch fix the call trace? Also
> can you tell which conditions led to this trace.
> 
> Thanks,
> --Rasesh

Hi Rasesh,

Please review my reply/patch2 to Dave. I guess the condition to reproduce is to simply insmod/modprobe the driver on the Brocade 1020 CNA . I don't have cables attached to the card if that helps.

Thanks,
Shyam
