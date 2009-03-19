From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: IPv6 address printf format specifier
Date: Thu, 19 Mar 2009 12:11:27 -0400
Message-ID: <2810B800-C22B-4EB6-97FC-80FBDCD955FE@oracle.com>
References: <49BE889C.8080602@hp.com> <20090318.185826.221840814.davem@davemloft.net> <49C1AD56.5000608@hp.com> <20090318.223013.142429036.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet12.oracle.com ([148.87.113.124]:49404 "EHLO
	rgminet12.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757260AbZCSQLk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Mar 2009 12:11:40 -0400
In-Reply-To: <20090318.223013.142429036.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mar 19, 2009, at Mar 19, 2009, 1:30 AM, David Miller wrote:
> From: Vlad Yasevich <vladislav.yasevich@hp.com>
> Date: Wed, 18 Mar 2009 22:26:30 -0400
>
>> There are multiple different forms of presenting addresses, all of
>> which are valid and non of which will provide for sting equality.
>> Regardless of how we represent our IPv6 addresses, there is a chance
>> that it will cause interoperability issues and the only way to truly
>> solve it is to change applications to compare addresses in their
>> true numerical representation.
>
> Or to, they themselves, canonicalize the text representation before
> comparison.

Thanks, this was helpful.

We had considered converting the string address to a sockaddr and back  
in user space, and that sounds like a good way to ensure we get the  
same presentation address for comparison.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
