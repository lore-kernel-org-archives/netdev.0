From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH][PPPOL2TP]: Fix SMP oops in pppol2tp driver
Date: Mon, 11 Feb 2008 19:57:20 +0100
Message-ID: <47B09A90.7040508@gmail.com>
References: <200802110922.m1B9MKQ4003674@quickie.katalix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: James Chapman <jchapman@katalix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.169]:5551 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750919AbYBKSyI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Feb 2008 13:54:08 -0500
Received: by ug-out-1314.google.com with SMTP id z38so347091ugc.16
        for <netdev@vger.kernel.org>; Mon, 11 Feb 2008 10:54:05 -0800 (PST)
In-Reply-To: <200802110922.m1B9MKQ4003674@quickie.katalix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

James Chapman wrote, On 02/11/2008 10:22 AM:

> Fix locking issues in the pppol2tp driver which can cause a kernel
> crash on SMP boxes when hundreds of L2TP sessions are created/deleted
> simultaneously (ISP environment). The driver was violating read_lock()
> and write_lock() scheduling rules so we now consistently use the _irq
> variants of the lock functions.
... 

Hi,

Could you explain what exactly scheduling rules do you mean here,
and why disabling interrupts is the best solution for this?

Thanks,
Jarek P.
