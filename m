From: Rick Jones <rick.jones2@hp.com>
Subject: Re: DF, IP ID always 0 and the reassembly protections
Date: Tue, 20 Jun 2006 17:35:50 -0700
Message-ID: <44989466.5070308@hp.com>
References: <44988877.2030205@hp.com> <20060620.171912.70221261.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:4996 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S932222AbWFUAgF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jun 2006 20:36:05 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060620.171912.70221261.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Tue, 20 Jun 2006 16:44:55 -0700
> 
> 
>>Doesn't that mechanism rely on watching the IP ID's between the pair of 
>>IPs?  For both fragmented and non-fragmented datagrams? If so, does 
>>always setting the IP ID to zero when DF is set affect that mechanism?
> 
> 
> Only the IDs in packets with DF clear matter.

I thought the ID's even in non-fragmented datagrams gave an idea of how 
many IP datagrams had been sent along, and so an idea of how "unlikely" 
it was that a datagram with holes could be reassembled?

rick jones
