From: Rasesh Mody <rmody@brocade.com>
Subject: RE: [PATCH] [net][bna] Fix call trace when interrupts are disabled
 while sleeping function  kzalloc is called
Date: Mon, 27 Jun 2011 17:51:07 -0700
Message-ID: <E5313AF6F2BFD14293E5FD0F94750F86A82D66F4FF@HQ1-EXCH01.corp.brocade.com>
References: <1309206092-23064-1-git-send-email-shyam_iyer@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "ddutt@brocadel.com" <ddutt@brocadel.com>,
	Shyam Iyer <shyam_iyer@dell.com>,
	Jing Huang <huangj@Brocade.COM>
To: Shyam Iyer <shyam.iyer.t@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-000f0801.pphosted.com ([67.231.152.113]:56555 "EHLO
	mx0b-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755761Ab1F1A6l convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 27 Jun 2011 20:58:41 -0400
In-Reply-To: <1309206092-23064-1-git-send-email-shyam_iyer@dell.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


>From: Shyam Iyer [mailto:shyam.iyer.t@gmail.com]
>Sent: Monday, June 27, 2011 1:22 PM
>Subject: [PATCH] [net][bna] Fix call trace when interrupts are disabled
>while sleeping function kzalloc is called
>
>The kzalloc sleeps and disabling interrupts(spin_lock_irqsave) causes
>oops like the one.

Hi Shyam,

We are not calling any sleeping function while holding the lock in bnad_mbox_irq_alloc(). How would your patch fix the call trace? Also can you tell which conditions led to this trace.

Thanks,
--Rasesh
