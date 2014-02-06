From: Sridhar Samudrala <samudrala.sridhar@gmail.com>
Subject: Re: VLAN ID 0 with priority tagging
Date: Thu, 06 Feb 2014 15:53:30 -0800
Message-ID: <52F4207A.6020408@gmail.com>
References: <52E05901.6050601@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f44.google.com ([209.85.219.44]:46440 "EHLO
	mail-oa0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751004AbaBFXx0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Feb 2014 18:53:26 -0500
Received: by mail-oa0-f44.google.com with SMTP id g12so3324973oah.31
        for <netdev@vger.kernel.org>; Thu, 06 Feb 2014 15:53:25 -0800 (PST)
Received: from [192.168.1.4] (static-50-53-49-166.bvtn.or.frontiernet.net. [50.53.49.166])
        by mx.google.com with ESMTPSA id b2sm15275043oed.7.2014.02.06.15.53.24
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Thu, 06 Feb 2014 15:53:25 -0800 (PST)
In-Reply-To: <52E05901.6050601@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 1/22/2014 3:49 PM, Sridhar Samudrala wrote:
> I am trying to send a packet with VLAN ID 0 and non-zero priority.
>
> The VLAN interfaces are created on 2 hosts using
>     ip link add link eth1 eth1.0 type vlan id 0 egress-qos-map 0:2
>
> When i try to send a packet using ping/arping, on the sender side tcpdump
> shows that the VLAN tag is added with ID 0 and priority 2.
>
> However, the receiver is receiving the packet with vlan tag stripped.
>
> I am seeing the same behavior with multiple NICs and also with a 
> switch in
> between the 2 hosts or with the 2 hosts connected over loopback cable.
>
> It looks as if the driver on the send side is stripping the tag if 
> vlan id is 0.
> Is this correct behavior or a bug?
> Any clues on how to  get priority tagging to work with vlan id 0?
>
I sent this note a few weeks back, but i haven't seen any response so far.

Is priority tagging with VLAN ID 0 not supported or is this a bug?
It looks like the NIC hardware is stripping the VLAN tag if the id is 0 
even when VLAN tag
is added by the software.

Thanks
Sridhar
