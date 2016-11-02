From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: SNMP read-write MIBs
Date: Wed, 2 Nov 2016 10:47:27 -0400
Message-ID: <5819FC7F.1090607@ti.com>
References: <5818D9B0.60907@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
        "eric.dumazet@gmail.com >> Eric Dumazet" <eric.dumazet@gmail.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([198.47.19.11]:45852 "EHLO bear.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750765AbcKBOr0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 2 Nov 2016 10:47:26 -0400
In-Reply-To: <5818D9B0.60907@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ David, Eric,

On 11/01/2016 02:06 PM, Murali Karicheri wrote:
> Hello netdev experts,
> 
> I am investigating the requirements to support hsr/prp SNMP functions in kernel.
> Based on my investigation so far, the kernel include file include/net/snmp.h
> defines all of the SNMP MIBS related defines and structures. But the MIBs are
> read-only type MIBs. Is there any implementation of read-write MIBs in kernel?
> 
> One of the specs for MIBs that are investigating have read-write MIBs and
> wondering if we have any precedence of such MIBs implemented in kernel space.
> If not, what is the suggested way to implement these MIBs in kernel space?
> 
> I assume that to implement read-only MIBs for hsr driver, I need to add
> them to snmp.h and use standard Macros in snmp.h to update them from the driver.
> 
> Thanks
>  
> Murali Karicheri
> Linux Kernel, Keystone
> 
I did some more research on this, and found some of the (not sure if there is any
in kernel) read-write MIBs are implemented in the net-snmp, where
it communicate using a raw socket and calling an ioctl. Is this the way to go
to implement the read-write MIBs?

Thanks
-- 
Murali Karicheri
Linux Kernel, Keystone
