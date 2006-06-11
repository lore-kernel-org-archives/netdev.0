From: Arjan van de Ven <arjan@linux.intel.com>
Subject: Re: [patch 7/8] lock validator: fix ns83820.c irq-flags bug
Date: Sun, 11 Jun 2006 10:02:35 -0700
Message-ID: <448C4CAB.7060506@linux.intel.com>
References: <200606090519.k595JmDG032032@shell0.pdx.osdl.net> <448C4C7A.7020301@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, mingo@elte.hu,
	bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmr17.intel.com ([134.134.136.16]:24790 "EHLO
	orsfmr002.jf.intel.com") by vger.kernel.org with ESMTP
	id S1750906AbWFKRDe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Jun 2006 13:03:34 -0400
To: Jeff Garzik <jeff@garzik.org>
In-Reply-To: <448C4C7A.7020301@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


> The above code snippet removes the nested unlock-irq, but now the code 
> is unbalanced, so IMO this patch _adds_ confusion.
> 
> I think the conservative patch for 2.6.17 is the one I have attached. 
> Unless there are objections, that is what I will forward...


this looks entirely fair and reasonable

Acked-by: Arjan van de Ven <arjan@linux.intel.com>
