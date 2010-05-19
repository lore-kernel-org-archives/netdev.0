From: "Philip A. Prindeville" <philipp@redfish-solutions.com>
Subject: Re: Network QoS support in applications
Date: Tue, 18 May 2010 18:04:59 -0600
Message-ID: <4BF32B2B.6010202@redfish-solutions.com>
References: <87my01m0zm.fsf@purkki.valot.fi>	<4B5EF5DF.2070005@lemonia.org>	<4B9942A7.40205@redfish-solutions.com> <20100311.112754.142886660.davem@davemloft.net> <4B9944A0.5080308@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: dunc@lemonia.org, kalle.valo@iki.fi, kaber@trash.net,
	netdev@vger.kernel.org, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.redfish-solutions.com ([66.232.79.143]:46162 "EHLO
	mail.redfish-solutions.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754153Ab0ESAWs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 20:22:48 -0400
In-Reply-To: <4B9944A0.5080308@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/11/2010 12:29 PM, Philip A. Prindeville wrote:
> On 03/11/2010 12:27 PM, David Miller wrote:
>   
>> From: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
>> Date: Thu, 11 Mar 2010 12:21:11 -0700
>>
>>     
>>> And yes, there will always be misbehaving users.  They are a fact of
>>> life.  That doesn't mean we should lobotomize the network.  We don't
>>> have an authentication mechanism on ICMP Redirects or Source-Quench,
>>>       
>> Which is why most networks block those packets from the outside.
>>
>>     
>>> Nor is ARP authenticated.
>>>       
>> Which is why people control who can plug into their physical
>> network.
>>
>> None of the things you are saying support the idea of having
>> applications decide what the DSCP marking should be.
>>     
>
> Does "decide what the DSCP marking should be" include complying to the recommendations of RFC-4594?
>   

If anyone cares, here's an update:

I've submitted patches for QoS configuration for:

APR/Apache (stalled);
Proftpd (committed);
Openssh (pending review);
Firefox/Thunderbird (reviewed and on-track for commit);
Cyrus (committed);
Sendmail (submittted and acknowledged, but not yet reviewed);
Curl (stalled);

All, as per the request of the maintainers, default to either no QoS
markings or previous RFC-791 QoS markings if that's what they already
supported (Proftpd and Openssh).

If anyone can think of anything else that needs to be supported to
impact a significant portion of network (or enterprise intranet)
traffic, please call it out.

And if anyone wants to see if they can help get Apache unstalled (it's
mostly an autoconf issue with Solaris that's holding things up), please
give me a holler offline.

Thanks.



