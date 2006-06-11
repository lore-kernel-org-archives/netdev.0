From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [patch 7/8] lock validator: fix ns83820.c irq-flags bug
Date: Sun, 11 Jun 2006 08:00:14 -0700
Message-ID: <448C2FFE.3010002@linux.intel.com>
References: <200606090519.k595JmDG032032@shell0.pdx.osdl.net> <448C2EEE.1020405@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, mingo@elte.hu,
	bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:8911 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1751622AbWFKPBE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 11:01:04 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <448C2EEE.1020405@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jeff Garzik wrote:
> The driver's locking is definitely wrong, but I don't think this is the 
> fix, 

it's an obvious correct fix in the correctness sense though...

> 
> Jesus, the locking here is awful.  No wonder there are bugs.


... which given that fact, is for 2.6.17 probably the right thing, pending
a nicer fix for 2.6.18

I fully agree with you that the locking is trying to be WAAAY too smart
for it's own good, and that a much simpler scheme is called for.

