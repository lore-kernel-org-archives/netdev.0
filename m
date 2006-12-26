From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 06/14] e1000: disable TSO on the 82544 with slab debugging
Date: Tue, 26 Dec 2006 16:28:31 -0500
Message-ID: <459193FF.2040209@garzik.org>
References: <E1GvNyb-0005yf-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: arjan@linux.intel.com, netdev@vger.kernel.org,
	jesse.brandeburg@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41437 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932796AbWLZV2i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Dec 2006 16:28:38 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1GvNyb-0005yf-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Jeff Garzik <jeff@garzik.org> wrote:
>>  
>>> +#ifdef CONFIG_DEBUG_SLAB
>>> +     /* 82544's work arounds do not play nicely with DEBUG SLAB */
>>> +     if (adapter->hw.mac_type == e1000_82544)
>>> +             netdev->features &= ~NETIF_F_TSO;
>>> +#endif
>> NAK, same reason as the others
> 
> Any chance you could apply this patch instead? I've verified that this
> does resolve the problem on 82544.
> 
> [NETDRV] e1000: Do not truncate TSO TCP header with 82544 workaround

applied


