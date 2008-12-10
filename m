From: Anthony Liguori <anthony@codemonkey.ws>
Subject: Re: [PATCH] virtio_net: add link status handling
Date: Tue, 09 Dec 2008 21:11:39 -0600
Message-ID: <493F336B.5010402@codemonkey.ws>
References: <1228817973.26198.1.camel@blaa> <493EE3DE.7080702@codemonkey.ws> <200812101023.42365.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Mark McLoughlin <markmc@redhat.com>,
	netdev <netdev@vger.kernel.org>, kvm <kvm@vger.kernel.org>
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:11441 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753596AbYLJDLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 22:11:44 -0500
Received: by an-out-0708.google.com with SMTP id d40so144057and.1
        for <netdev@vger.kernel.org>; Tue, 09 Dec 2008 19:11:43 -0800 (PST)
In-Reply-To: <200812101023.42365.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rusty Russell wrote:
> On Wednesday 10 December 2008 08:02:14 Anthony Liguori wrote:
>   
>> Mark McLoughlin wrote:
>>     
>>> Allow the host to inform us that the link is down by adding
>>> a VIRTIO_NET_F_STATUS which indicates that device status is
>>> available in virtio_net config.
>>>
>>> This is currently useful for simulating link down conditions
>>> (e.g. using proposed qemu 'set_link' monitor command) but
>>> would also be needed if we were to support device assignment
>>> via virtio.
>>>       
>> It would be nice if the virtio-net card wrote some acknowledgement that 
>> it has received the link status down/up events.
>>     
>
> How about of every status change event? ie. a generic virtio_pci solution?
>   

A really simple way to do it would just be to have another status field 
that was the guest's status (verses the host requested status which the 
current field is).  All config reads/writes result in exits so it's easy 
to track.

Adding YA virtio event may be a little overkill.

Regards,

Anthony Liguori

> Rusty.
>   

