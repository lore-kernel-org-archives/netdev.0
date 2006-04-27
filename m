From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 8/9] forcedeth: suggested cleanups
Date: Thu, 27 Apr 2006 05:56:49 -0400
Message-ID: <44509561.3090006@garzik.org>
References: <200604270932.k3R9WD14025332@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ioe-lkml@rameria.de,
	manfred@colorfullife.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:11429 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S965055AbWD0J4v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2006 05:56:51 -0400
To: akpm@osdl.org
In-Reply-To: <200604270932.k3R9WD14025332@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@osdl.org wrote:
> From: Ingo Oeser <ioe-lkml@rameria.de>
> 
> general:
> 	- endian annotation of the ring descriptors
> 
> nv_getlen():
> 	- use htons() instead of __constant_htons()
>           to improvde readability and let the compiler constant fold it.
> 
> nv_rx_process():
> 	- use a real for() loop in processing instead of goto and break
> 	- consolidate rx_errors increment
> 	- count detected rx_length_errors
> 
> Signed-off-by: Ingo Oeser <ioe-lkml@rameria.de>
> Cc: Manfred Spraul <manfred@colorfullife.com>
> Signed-off-by: Andrew Morton <akpm@osdl.org>

ACK, but I'm holding off applying this while trying to get 4 apply-able 
patches out of NVIDIA and Manfred :)

	Jeff



