From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: DSA vs. SWTICHDEV ?
Date: Thu, 1 Dec 2016 16:38:47 -0500
Message-ID: <58409867.50001@ti.com>
References: <1480495831.3563.135.camel@infinera.com> <584054C4.1010809@ti.com>
 <20161201173100.GG21887@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Joakim Tjernlund <Joakim.Tjernlund@infinera.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        Roger Quadros <rogerq@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx209.ext.ti.com ([198.47.19.16]:65409 "EHLO
        fllnx209.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758058AbcLAViy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 16:38:54 -0500
In-Reply-To: <20161201173100.GG21887@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,
On 12/01/2016 12:31 PM, Andrew Lunn wrote:
> Hi Murali 
> 
>> 2. Switch mode where it implements a simple Ethernet switch. Currently
>>    it doesn't have address learning capability, but in future it
>>    can.
> 
> If it does not have address learning capabilities, does it act like a
> plain old hub? What comes in one port goes out all others?

Thanks for the response!

Yes. It is a plain hub. it replicates frame to both ports. So need to
run a bridge layer for address learning in software.

> 
> Or can you do the learning in software on the host and program tables,
> which the hardware then uses?
> 

I think not. I see we have a non Linux implementation that does address
learning in software using a hash table and look up MAC for each packet
to see which port it needs to be sent to.

Murali

>> 3. Switch with HSR/PRP offload where it provides HSR/PRP protocol
>>    support and cut through switch.
>>
>> So a device need to function in one of the modes. A a regular Ethernet
>> driver that provides two network devices, one per port, and switchdev
>> for each physical port (in switch mode) will look ideal in this case.
> 
> Yes, this seems the right model to use.
> 
>      Andrew
> 


-- 
Murali Karicheri
Linux Kernel, Keystone
