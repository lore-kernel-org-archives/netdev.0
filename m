From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] VSOCK: add loopback to virtio_transport
Date: Sat, 19 Nov 2016 22:16:43 -0500 (EST)
Message-ID: <20161119.221643.2303914168886226654.davem@davemloft.net>
References: <1479397763-22319-1-git-send-email-stefanha@redhat.com>
        <20161119.220804.755313313976863187.davem@davemloft.net>
        <58311507.7070707@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stefanha@redhat.com, netdev@vger.kernel.org, cavery@redhat.com,
        imbrenda@linux.vnet.ibm.com, jhansen@vmware.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45970 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753033AbcKTDQp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 19 Nov 2016 22:16:45 -0500
In-Reply-To: <58311507.7070707@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sat, 19 Nov 2016 19:14:15 -0800

> On 16-11-19 07:08 PM, David Miller wrote:
>> From: Stefan Hajnoczi <stefanha@redhat.com>
>> Date: Thu, 17 Nov 2016 15:49:23 +0000
>> 
>>> @@ -159,6 +199,10 @@ virtio_transport_send_pkt(struct virtio_vsock_pkt *pkt)
>>>  		return -ENODEV;
>>>  	}
>>>  
>>> +	if (le32_to_cpu(pkt->hdr.dst_cid) == vsock->guest_cid) {
>>> +		return virtio_transport_send_pkt_loopback(vsock, pkt);
>>> +	}
>>> +
>> 
>> A single-statement basic block should get surrounding curly
>> braces.
>> 
> 
> Should _not_ get curly braces in case it wasn't obvious ;)

Indeed, thanks for the correction :)
