From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v1 3/4] vxlan: add ipv6 support
Date: Mon, 01 Apr 2013 14:15:48 -0400 (EDT)
Message-ID: <20130401.141548.1477224368912481541.davem@davemloft.net>
References: <OF5EB046E4.6295C3A5-ON85257B40.00537077-85257B40.00542577@us.ibm.com>
	<20130401.130223.1527520446382659798.davem@davemloft.net>
	<OF1E30BC31.571FBD44-ON85257B40.005F5AF2-85257B40.0063627F@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org, stephen@networkplumber.org
To: dlstevens@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58079 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756575Ab3DASPw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Apr 2013 14:15:52 -0400
In-Reply-To: <OF1E30BC31.571FBD44-ON85257B40.005F5AF2-85257B40.0063627F@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Stevens <dlstevens@us.ibm.com>
Date: Mon, 1 Apr 2013 14:05:37 -0400

>         I guess, but in this case, I'm not saying it's like a sockaddr 
> with
> device-specific requirements. Rather, I'm saying it's exactly a sockaddr--
> it is either a sockaddr_in or a sockaddr_in6 and a family field to say
> which.

in6_addr, which is what sockaddr_in6 is composed of, is precisely the
problematic type that we want to avoid to elide the double definition
error.

http://www.spinics.net/linux/fedora/libvir/msg70921.html

It's really not safe to use at the moment.

We're not creating more instances of this mess, and that decision
is final.
