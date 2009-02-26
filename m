From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel
 module
Date: Thu, 26 Feb 2009 15:17:53 -0500
Message-ID: <49A6F8F1.4060104@hp.com>
References: <49A5ADB3.2010709@hp.com> <28797.1235599858@death.nxdomain.ibm.com> <20090225.141430.166906161.davem@davemloft.net> <49A6C6ED.3070801@hp.com> <22876.1235672073@death.nxdomain.ibm.com> <49A6ED6D.3090508@hp.com> <F613EEFD-2332-4C75-A486-73CDF2BAADDE@oracle.com> <49A6F50E.3070100@hp.com> <2FBB0F50-8763-4A17-8734-5940FC3FF26A@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Brian Haley <brian.haley@hp.com>, Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, arvidjaar@mail.ru,
	tytso@mit.edu, Valdis.Kletnieks@vt.edu, rjw@sisk.pl,
	netdev@vger.kernel.org, bonding-devel@lists.sourceforge.net,
	jamagallon@ono.com, linux-kernel@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:10840 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751771AbZBZUR5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:17:57 -0500
In-Reply-To: <2FBB0F50-8763-4A17-8734-5940FC3FF26A@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> On Feb 26, 2009, at Feb 26, 2009, 3:01 PM, Brian Haley wrote:
>> Chuck Lever wrote:
>>>> I think changing ipv6 to support a disable_ipv6 module parameter
>>>> like Vlad suggested would work, as long as we're not worried about
>>>> someone opening an AF_INET6 socket - even if they do they won't get
>>>> anywhere.
>>> In this case, if IPV6ONLY is set on an AF_INET6 listener, it should
>>> still get AF_INET traffic, correct?
>>
>> No, it should get nothing, and a send should get ENETUNREACH.
> 
> Sorry, I got my logic backwards.  If IPV6ONLY is intentionally cleared
> on an AF_INET6 socket, it should still be able to handle AF_INET traffic.

Yes. :-)

-vlad

> 
> -- 
> Chuck Lever
> chuck[dot]lever[at]oracle[dot]com
> 

