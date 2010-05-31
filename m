From: Philip Prindeville <philipp_subx@redfish-solutions.com>
Subject: Re: Network QoS support in applications
Date: Mon, 31 May 2010 14:28:26 -0600
Message-ID: <4C041BEA.2010303@redfish-solutions.com>
References: <87my01m0zm.fsf@purkki.valot.fi>	<4B5EF5DF.2070005@lemonia.org>	<4B9942A7.40205@redfish-solutions.com>	<20100311.112754.142886660.davem@davemloft.net>	<4B9944A0.5080308@redfish-solutions.com>	<4BF32B2B.6010202@redfish-solutions.com> <AANLkTindWCmxtAJU5R3ey_18_3wNUuMGc-jq_EY_itiN@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, dunc@lemonia.org,
	kalle.valo@iki.fi, kaber@trash.net, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Ben Gardiner <bengardiner@nanometrics.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:50783 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751279Ab0EaUau (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 May 2010 16:30:50 -0400
In-Reply-To: <AANLkTindWCmxtAJU5R3ey_18_3wNUuMGc-jq_EY_itiN@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/31/10 1:30 PM, Ben Gardiner wrote:
> On Tue, May 18, 2010 at 8:04 PM, Philip A. Prindeville
> <philipp@redfish-solutions.com>  wrote:
>    
>> On 03/11/2010 12:29 PM, Philip A. Prindeville wrote:
>>      
>>> On 03/11/2010 12:27 PM, David Miller wrote:
>>>
>>>        
>>>> From: "Philip A. Prindeville"<philipp_subx@redfish-solutions.com>
>>>> Date: Thu, 11 Mar 2010 12:21:11 -0700
>>>>
>>>>
>>>>          
>>>>> And yes, there will always be misbehaving users.  They are a fact of
>>>>> life.  That doesn't mean we should lobotomize the network.  We don't
>>>>> have an authentication mechanism on ICMP Redirects or Source-Quench,
>>>>>
>>>>>            
>>>> Which is why most networks block those packets from the outside.
>>>>
>>>>
>>>>          
>>>>> Nor is ARP authenticated.
>>>>>
>>>>>            
>>>> Which is why people control who can plug into their physical
>>>> network.
>>>>
>>>> None of the things you are saying support the idea of having
>>>> applications decide what the DSCP marking should be.
>>>>
>>>>          
>>> Does "decide what the DSCP marking should be" include complying to the recommendations of RFC-4594?
>>>
>>>        
>> If anyone cares, here's an update:
>>
>> I've submitted patches for QoS configuration for:
>>
>> APR/Apache (stalled);
>> Proftpd (committed);
>> Openssh (pending review);
>> Firefox/Thunderbird (reviewed and on-track for commit);
>> Cyrus (committed);
>> Sendmail (submittted and acknowledged, but not yet reviewed);
>> Curl (stalled);
>>
>> All, as per the request of the maintainers, default to either no QoS
>> markings or previous RFC-791 QoS markings if that's what they already
>> supported (Proftpd and Openssh).
>>
>> If anyone can think of anything else that needs to be supported to
>> impact a significant portion of network (or enterprise intranet)
>> traffic, please call it out.
>>      
> wget [1], like curl, is used for downloads of artifacts by some build systems.
>
> [1] http://www.gnu.org/software/wget/
>
>    

Ok, but I'm not sure that changes anything... what I was asking about 
was other services not enumerated: not how the above services are used.  
Sorry that wasn't clear.

-Philip




