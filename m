From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] IPv6: optimize echo reply checksum calculation
Date: Fri, 10 Nov 2006 12:51:19 -0500
Message-ID: <4554BC17.8020809@hp.com>
References: <20061108221332.GI29920@ftp.linux.org.uk> <45536622.90708@hp.com> <20061109.151402.15590179.davem@davemloft.net> <4554A811.5060402@hp.com> <20061110173422.GM29920@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel8.hp.com ([156.153.255.206]:33974 "EHLO atlrel8.hp.com")
	by vger.kernel.org with ESMTP id S1161906AbWKJRvV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Nov 2006 12:51:21 -0500
To: Al Viro <viro@ftp.linux.org.uk>
In-Reply-To: <20061110173422.GM29920@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Viro wrote:
> On Fri, Nov 10, 2006 at 11:25:53AM -0500, Brian Haley wrote:
>> Since the only difference between echo requests and echo replies is the 
>> ICMPv6 type value (which is a difference of 1), just subtracting one 
>> from the request checksum will result in the correct checksum for the reply.
> 
> Um, no.  That will *not* result in correct checksum.  Please, RTFRFC 1071.

I verified this works for echo request/reply on my IA64 box, 
double-checked with ethereal/wireshark.  Is there something specific in 
RFC 1071 that I should be looking for?

-Brian
