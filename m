From: Chuck Lever <chuck.lever@oracle.com>
Subject: Re: [PATCH v2] bonding: move IPv6 support into a separate kernel module
Date: Thu, 26 Feb 2009 15:12:48 -0500
Message-ID: <2FBB0F50-8763-4A17-8734-5940FC3FF26A@oracle.com>
References: <49A5ADB3.2010709@hp.com> <28797.1235599858@death.nxdomain.ibm.com> <20090225.141430.166906161.davem@davemloft.net> <49A6C6ED.3070801@hp.com> <22876.1235672073@death.nxdomain.ibm.com> <49A6ED6D.3090508@hp.com> <F613EEFD-2332-4C75-A486-73CDF2BAADDE@oracle.com> <49A6F50E.3070100@hp.com>
Mime-Version: 1.0 (Apple Message framework v930.3)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	David Miller <davem@davemloft.net>, arvidjaar@mail.ru,
	vladislav.yasevich@hp.com, tytso@mit.edu, Valdis.Kletnieks@vt.edu,
	rjw@sisk.pl, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net, jamagallon@ono.com,
	linux-kernel@vger.kernel.org
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from acsinet11.oracle.com ([141.146.126.233]:36667 "EHLO
	acsinet11.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753028AbZBZUOE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2009 15:14:04 -0500
In-Reply-To: <49A6F50E.3070100@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Feb 26, 2009, at Feb 26, 2009, 3:01 PM, Brian Haley wrote:
> Chuck Lever wrote:
>>> I think changing ipv6 to support a disable_ipv6 module parameter  
>>> like Vlad suggested would work, as long as we're not worried about  
>>> someone opening an AF_INET6 socket - even if they do they won't  
>>> get anywhere.
>> In this case, if IPV6ONLY is set on an AF_INET6 listener, it should  
>> still get AF_INET traffic, correct?
>
> No, it should get nothing, and a send should get ENETUNREACH.

Sorry, I got my logic backwards.  If IPV6ONLY is intentionally cleared  
on an AF_INET6 socket, it should still be able to handle AF_INET  
traffic.

--
Chuck Lever
chuck[dot]lever[at]oracle[dot]com
