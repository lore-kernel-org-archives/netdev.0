From: Rick Jones <rick.jones2@hp.com>
Subject: Re: lowpri - RTO for unidirectional reciever
Date: Tue, 09 Dec 2008 11:25:19 -0800
Message-ID: <493EC61F.7090806@hp.com>
References: <493DD199.6080600@hp.com> <20081208.235622.149344934.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0009.atlanta.hp.com ([15.192.0.46]:28270 "EHLO
	g5t0009.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754016AbYLITZX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 14:25:23 -0500
In-Reply-To: <20081208.235622.149344934.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> We should not use the SYN|ACK for RTT estimates.
> 
> It's a bug, and in fact we used to, but I fixed that long
> ago.
> 
> Since there is no data in the packet, and it's therefore very small
> compared to real data bearing packets, the RTT measured might be
> artificially small and not really representative.

A miracle occurs going from zero bytes of payload but several bytes of 
TCP options (scale and MSS) to having one byte of payload and no bytes 
of options? (Timestamp options remaining the same in both cases)

rick jones

