From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: Re: [net-next PATCH 0/4] Replace wmb()/rmb() with dma_wmb()/dma_rmb()
 where appropriate, round 2
Date: Wed, 08 Apr 2015 19:46:26 -0700
Message-ID: <5525E802.4060401@redhat.com>
References: <20150409014001.4434.85280.stgit@ahduyck-vm-fedora22> <20150408.223626.1930342094004430660.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:57785 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753651AbbDICq1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Apr 2015 22:46:27 -0400
In-Reply-To: <20150408.223626.1930342094004430660.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/08/2015 07:36 PM, David Miller wrote:
> From: Alexander Duyck <alexander.h.duyck@redhat.com>
> Date: Wed, 08 Apr 2015 18:49:23 -0700
>
>> More cleanup of drivers in order to start making use of dma_rmb and dma_wmb
>> calls.  This is another pass of what I would consider to be low hanging
>> fruit.  There may be other opportunities to make use of the barriers in the
>> Mellanox and Chelsio drivers but I didn't want to risk meddling with code I
>> was not completely familiar with so I am leaving that for future work.
>>
>> I have revisited the Mellanox driver changes.  This time around I went only
>> for the sections with a clearly defined pattern.  For dma_wmb I used it
>> between accesses of the descriptor bits followed by owner or size.  For
>> dma_wmb I used it to replace rmb following a read of the ownership bit in
>> the descriptor.
> That last sentence should be talking about "dma_rmb" instead of "dma_wmb"
> right?

Yeah, it was just a typo.

rmb -> dma_rmb
wmb-> dma_wmb

I'll double check my patches to be sure I didn't make the mistake 
anywhere in the code.

Thanks.

- Alex
