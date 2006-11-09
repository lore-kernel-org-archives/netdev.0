From: Paul Moore <paul.moore@hp.com>
Subject: Re: [PATCH 2/3] mlsxfrm: Various fixes
Date: Wed, 08 Nov 2006 23:59:45 -0500
Message-ID: <4552B5C1.8040007@hp.com>
References: <000501c70342$83b9df70$cc0a010a@tcssec.com> <4552A9AC.3060708@hp.com> <Pine.LNX.4.64.0611082337520.5916@d.namei>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: vyekkirala@TrustedCS.com, netdev@vger.kernel.org,
	selinux@tycho.nsa.gov, sds@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from ccerelrim04.cce.hp.com ([161.114.21.25]:11602 "EHLO
	ccerelrim04.cce.hp.com") by vger.kernel.org with ESMTP
	id S1753289AbWKIE75 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 Nov 2006 23:59:57 -0500
To: James Morris <jmorris@namei.org>
In-Reply-To: <Pine.LNX.4.64.0611082337520.5916@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

James Morris wrote:
> On Wed, 8 Nov 2006, Paul Moore wrote:
> 
>>1. Functionality is available right now, no additional kernel changes needed
>>2. No special handling for localhost, I tend to like the idea of having
>>consistent behavior for all addresses/interfaces
> 
> I don't agree.  SO_PEERSEC should always just work for loopback, just like 
> with Unix sockets.

My main concern is that we would have "special" behavior for a single IP address
   and that this behavior wouldn't be subject to the same labeled networking
configuration/management methods as the rest of the address space.  Treating
localhost like any other IP address seems consistent with the way we handle Unix
sockets - we don't have any special handling depending on the path of the socket.

-- 
paul moore
linux security @ hp
