From: Ben Greear <greearb@candelatech.com>
Subject: Re: IP address: property of host or interface?
Date: Mon, 26 Jan 2009 10:06:58 -0800
Message-ID: <497DFBC2.4030903@candelatech.com>
References: <497B1E5E.9050309@msgid.tls.msk.ru> <497DF629.70602@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Michael Tokarev <mjt@tls.msk.ru>, netdev <netdev@vger.kernel.org>
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:50830 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751621AbZAZSHT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jan 2009 13:07:19 -0500
In-Reply-To: <497DF629.70602@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rick Jones wrote:
>> So.. am I right that an IP address is a HOST property, not an INTERFACE
>> property, and that the traditional way is just more convenient to set 
>> up? And
>> that all the tools that complains that "there's no IP address 
>> assigned to this
>> interface" (tcpdump) are wrong? :)
>
> There are two "schools" of thought - the Linux stack follows the "weak 
> end system" model in which IP addresses are treated as a host 
> property.  There is another school of thought called the "strong end 
> system" model where IP addresses are an interface property.  There are 
> some "other" stacks out there which can be configured to behave in a 
> "strong end system" way but they tend to default to more of something 
> in between the two.
>
> Tcpdump may simply be caught in the middle :)
With a bit of configuring (away from system defaults), Linux can behave 
as a 'strong end system', and even
in default behaviour, I don't believe it will process IP packets from an 
interface that has NO IP address assigned
to it.

Thanks,
Ben

>
> rick jones
> -- 
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html


-- 
Ben Greear <greearb@candelatech.com> 
Candela Technologies Inc  http://www.candelatech.com


