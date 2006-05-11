From: Rick Jones <rick.jones2@hp.com>
Subject: Re: Initial benchmarks of some VJ ideas [mmap memcpy vs copy_to_user].
Date: Thu, 11 May 2006 12:30:31 -0700
Message-ID: <446390D7.8000709@hp.com>
References: <20060511.000721.60889163.davem@davemloft.net>	<20060511083031.GA12712@2ka.mipt.ru>	<20060511161815.GA623@2ka.mipt.ru> <20060511.115409.89709859.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org, caitlinb@broadcom.com,
	kelly@au1.ibm.com, rusty@rustcorp.com.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:27884 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1750721AbWEKTad (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 May 2006 15:30:33 -0400
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060511.115409.89709859.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 11 May 2006 20:18:15 +0400
> 
> 
>>Here is profile result:
>>1463625  78.0003  poll_idle
>>19171     1.0217  _spin_lock_irqsave
>>15887     0.8467  _read_lock
>>14712     0.7840  kfree
>>13370     0.7125  ip_frag_queue
>>11896     0.6340  delay_pmtmr
>>11811     0.6294  _spin_lock
>>11723     0.6247  csum_partial
>>11399     0.6075  ip_frag_destroy
>>11063     0.5896  serial_in
>>10533     0.5613  skb_release_data
>>10524     0.5609  ip_route_input
>>10319     0.5499  __alloc_skb
> 
> 
> Too bad spinlocks are not inlined any longer, this makes oprofile
> output so much less useful.

But it is nice to see how much time is being spent in "locking"

rick jones

