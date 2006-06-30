From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH 39 of 39] IB/ipath - use streaming copy in RDMA	interrupt
 handler to reduce packet loss
Date: Thu, 29 Jun 2006 17:44:05 -0700
Message-ID: <44A473D5.70809@hp.com>
References: <1151624063.10886.34.camel@chalcedony.pathscale.com>	<20060629.164623.59469884.davem@davemloft.net>	<44A47042.8060203@hp.com> <20060629.173206.48800902.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: bos@pathscale.com, akpm@osdl.org, rdreier@cisco.com,
	mst@mellanox.co.il, openib-general@openib.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel12.hp.com ([156.153.255.237]:43981 "EHLO palrel12.hp.com")
	by vger.kernel.org with ESMTP id S1751338AbWF3AoH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2006 20:44:07 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060629.173206.48800902.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: Rick Jones <rick.jones2@hp.com>
> Date: Thu, 29 Jun 2006 17:28:50 -0700
> 
> 
>>I thought that most PCI controllers (that is to say the things bridging 
>>PCI to the rest of the system) could do prefetching and/or that PCI-X 
>>(if not PCI, no idea about PCI-e) cards could issue multiple 
>>transactions anyway?
> 
> 
> People doing deep CMT chips have found out that all of that
> prefetching and store buffering is unnecessary when everything is so
> tightly integrated.

Then is prefetching in memcpy really that important to them (BTW besides 
  Sun/Niagra who are doing "deep CMT"?)

> All of the previous UltraSPARC boxes before Niagara had a
> streaming cache sitting on the PCI controller.  It basically
> prefetched for reads and collected writes from PCI devices
> into cacheline sized chunks.
> 
> The PCI controller in the current Niagara systems has none of that
> stuff.

Relying on PCI-X devices to issue multiple requests then?

rick jones
