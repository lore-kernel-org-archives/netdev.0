From: Santwona.Behera@Sun.COM
Subject: Re: [gkernel-commit] [PATCH 2/3] [kernel] Add support for RX packet
 classification in a network device
Date: Fri, 20 Feb 2009 09:19:29 -0800
Message-ID: <499EE621.6000605@Sun.COM>
References: <49999FA3.7040300@Sun.COM>
 <20090217.202838.66382200.davem@davemloft.net>
 <20090220.005532.166859047.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; format=flowed; charset=ISO-8859-1
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, gkernel-commit@lists.sourceforge.net,
	Matheos.Worku@Sun.COM, jeff@garzik.org, Mehdi.Bonyadi@Sun.COM
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sca-es-mail-1.Sun.COM ([192.18.43.132]:50843 "EHLO
	sca-es-mail-1.sun.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753657AbZBTRUZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Feb 2009 12:20:25 -0500
Received: from fe-sfbay-10.sun.com ([192.18.43.129])
	by sca-es-mail-1.sun.com (8.13.7+Sun/8.12.9) with ESMTP id n1KHJf1C001957
	for <netdev@vger.kernel.org>; Fri, 20 Feb 2009 09:19:54 -0800 (PST)
Received: from conversion-daemon.fe-sfbay-10.sun.com by fe-sfbay-10.sun.com
 (Sun Java(tm) System Messaging Server 7.0-3.01 64bit (built Dec 23 2008))
 id <0KFD00K00J54ZB00@fe-sfbay-10.sun.com> for netdev@vger.kernel.org; Fri,
 20 Feb 2009 09:19:41 -0800 (PST)
In-reply-to: <20090220.005532.166859047.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

I actually did make the changes and compile with sparse (without any 
warnings, at least for the access of these fields), but I haven't had 
the time to test it yet, which is why I did not post the new patches.

Thanks for taking care of it.

--santwona

On 02/20/09 12:55 AM, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Tue, 17 Feb 2009 20:28:38 -0800 (PST)
> 
>> From: Santwona.Behera@Sun.COM
>> Date: Mon, 16 Feb 2009 09:17:23 -0800
>>
>>> -struct ethtool_rxnfc {
>>> -	__u32		cmd;
>>> +/* The following structures are for supporting RX network flow
>>> + * classification configuration. Note, all multibyte fields, e.g.,
>>> + * ip4src, ip4dst, psrc, pdst, spi, etc. are expected to be in network
>>> + * byte order.
>>> + */
>>> +struct ethtool_tcpip4_spec {
>>> +	__u32	ip4src;
>>> +	__u32	ip4dst;
>>> +	__u16	psrc;
>>> +	__u16	pdst;
>>> +	__u8    tos;
>>> +};
>> We have specific types for this, "__be32" et al.
> 
> Nevermind, you obviously don't have time to get to this quickly
> so I'll take care of it while checking this stuff in...
> 

