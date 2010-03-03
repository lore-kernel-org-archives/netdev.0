From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: e1000e: reset of tx_queue_len
Date: Wed, 03 Mar 2010 15:22:59 +0100
Message-ID: <4B8E70C3.1020501@lastsummer.de>
References: <4B8D4E7E.2000805@lastsummer.de> <alpine.WNT.2.00.1003021020160.2888@jbrandeb-desk1.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Franco Fichtner <franco@lastsummer.de>,
	Netdev <netdev@vger.kernel.org>,
	"Allan, Bruce W" <bruce.w.allan@intel.com>
To: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:35587 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754306Ab0CCOXC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Mar 2010 09:23:02 -0500
In-Reply-To: <alpine.WNT.2.00.1003021020160.2888@jbrandeb-desk1.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jesse,

> Its possible we should just remove this code from the in-kernel 
> driver, as I don't think many other drivers mess with the tx_queue_len 
> either.  We did introduce the code to fix some users complaints about the 
> amount of work that can get queued up in the hardware with tx_queue_len = 
> 1000 when at 10/100 speeds.
>   

I've tested the changes you suggested and now tx_queue_len
is no longer reset. I have also prepared a patch for net-next
for you to sign or ack (or nack) because I'd like to see this go,
also.


Thanks again,
Franco
