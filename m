From: Rick Jones <rick.jones2@hp.com>
Subject: Re: using software TSO on non-TSO capable netdevices
Date: Thu, 07 Aug 2008 13:32:05 -0700
Message-ID: <489B5BC5.3030600@hp.com>
References: <20080731132735.GA9085@gondor.apana.org.au>	<20080803.011945.249059359.davem@davemloft.net>	<20080803085553.GA1512@gondor.apana.org.au> <20080806.230741.137564172.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, bhutchings@solarflare.com,
	buytenh@wantstofly.org, netdev@vger.kernel.org,
	akarkare@marvell.com, nico@cam.org, dale@farnsworth.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:43120 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288AbYHGUcL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2008 16:32:11 -0400
In-Reply-To: <20080806.230741.137564172.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> So I had this idea.  My goal is to minimize the number of DMA
> mappings the driver has to make.
> 
> We don't touch anything in the original TSO skb.  However we expand
> the headroom (if necessary) and in the area in front of skb->data we
> build the header areas for the sub-TSO frames, one by one.
> 
> We give the driver some iterator functions that walk through the
> header areas and compute offset/length pairs into the
> skb_shared_info() page list.

Is that like Solaris Multi Data Transmit?

rick jones
