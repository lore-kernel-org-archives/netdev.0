From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/3] mlsxfrm: Various fixes
Date: Thu, 09 Nov 2006 01:39:55 -0500
Message-ID: <4552CD3B.40809@hp.com>
References: <000501c70342$83b9df70$cc0a010a@tcssec.com> <4552A9AC.3060708@hp.com> <Pine.LNX.4.64.0611082337520.5916@d.namei> <4552B5C1.8040007@hp.com> <Pine.LNX.4.64.0611090109120.10907@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vyekkirala@TrustedCS.com, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.hp.com ([192.151.27.10]:17559 "EHLO mailhub.hp.com")
	by vger.kernel.org with ESMTP id S1161758AbWKIGj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 01:39:58 -0500
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0611090109120.10907@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Wed, 8 Nov 2006, Paul Moore wrote:
> 
>>James Morris wrote:
>>
>>>On Wed, 8 Nov 2006, Paul Moore wrote:
>>>
>>>>1. Functionality is available right now, no additional kernel changes needed
>>>>2. No special handling for localhost, I tend to like the idea of having
>>>>consistent behavior for all addresses/interfaces
>>>
>>>I don't agree.  SO_PEERSEC should always just work for loopback, just like 
>>>with Unix sockets.
>>
>>My main concern is that we would have "special" behavior for a single IP address
>>   and that this behavior wouldn't be subject to the same labeled networking
>>configuration/management methods as the rest of the address space.
>  
> It's a very special case, and loopack networking has lots of special case 
> handling because of this.  It's nearly zero cost to have this work, and 
> then you get full SELinux control over local IP communications.

It sounds like you have an idea of how you would like to see this implemented,
can you give me a rough outline?  Is this the partitioned SECMARK field you
talked about earlier?

I'm asking because the only localhost SO_PEERSEC mechanism that I have seen that
didn't require explicit packet labeling was the secid approach which I think we
gave up on ...

-- 
paul moore
linux security @ hp
