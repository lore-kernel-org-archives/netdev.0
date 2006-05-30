From: Herman Elfrink <herman.elfrink@ti-wmc.nl>
Subject: Re: [ANNOUNCE] FLAME: external kernel module for L2.5 meshing
Date: Tue, 30 May 2006 10:43:39 +0200
Message-ID: <447C05BB.30102@ti-wmc.nl>
References: <44731733.7000204@ti-wmc.nl>	 <1148395738.25255.68.camel@localhost.localdomain>	 <44731F2C.2010109@ti-wmc.nl> <20060523145549.GA22749@harddisk-recovery.com> <1148397268.25255.81.camel@localhost.localdomain> <447BE93D.2070605@ti-wmc.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Erik Mouw <erik@harddisk-recovery.com>,
	Simon Oosthoek <simon.oosthoek@ti-wmc.nl>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from darla.ti-wmc.nl ([217.114.97.45]:20399 "EHLO smtp.wmc")
	by vger.kernel.org with ESMTP id S932181AbWE3Ink (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 May 2006 04:43:40 -0400
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <447BE93D.2070605@ti-wmc.nl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

Seems that instead of clearing the confusion I was confused myself.
What we are talking about here is the protocol ID carried in the 
ethernet header, which ethernet uses to identify the network layer (as 
defined in the file <linux/if_ether.h>).
So its indeed IEEE to address for this, and not IANA.

Thanks for your help on this issue.

Herman.

Herman Elfrink wrote:

> An attempt to clear up the confusion that seems to have occurred:
> FLAME is an intermediate layer between existing MAC and network (IP) 
> layers.
> From MAC layer point of view FLAME is another network layer protocol 
> (besides IP, IPX etc.), so the FLAME protocol ID we are taking about 
> is a network layer (IANA) protocol number.
> From IP point of view FLAME behaves like a 'normal' ethernet-type MAC 
> layer; no need for new IEEE protocol number.
>
> Regards,
>
> Herman Elfrink.
>
> Alan Cox wrote:
>
>> On Maw, 2006-05-23 at 16:55 +0200, Erik Mouw wrote:
>>  
>>
>>>>> Ethernet protocol number I assume you mean. If so this at least 
>>>>> used to
>>>>> be handled by the IEEE, along with ethernet mac address ranges.
>>>>>
>>>>>       
>>>>
>>>> Yes ethernet protocol (it's below IP level), I didn't realise that 
>>>> IEEE also handled the portnumbers. I'll check the ieee website to 
>>>> see how it works, tnx!
>>>>     
>>>
>>> IEEE doesn't handle port numbers. Port numbers are for whatever is
>>> layered on top of ethernet, so you need to register those with the
>>> appropriate authorities (IANA for IP).
>>>   
>>
>>
>> No no no
>>
>> There are several sets of numbers here
>>
>> Each ethernet DIX frame has a "protocol" (its the bits used for length
>> in 802.*). IEEE at least used to handle the assignment of those. On top
>> of that you have IP, IPX, etc with their own numbering agency.
>>
>> As he said "ethernet protocol (it's below IP level)", those are the
>> protocol numbering bodies he wants, or to whomever it was delegated.
>>
>> Alan
>>
>>
>>  
>>
>
>

