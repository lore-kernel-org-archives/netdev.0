From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 0/14 (3 subsets)] Make tuns and vlans devices work per-net.
Date: Fri, 11 Apr 2008 17:42:54 +0200
Message-ID: <47FF86FE.7030209@fr.ibm.com>
References: <47FE2AD4.9080609@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Denis Lunev <den@openvz.org>,
	Linux Containers <containers@lists.osdl.org>,
	Benjamin Thery <benjamin.thery@bull.net>
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate7.de.ibm.com ([195.212.29.156]:39013 "EHLO
	mtagate7.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759976AbYDKPr3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2008 11:47:29 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate7.de.ibm.com (8.13.8/8.13.8) with ESMTP id m3BFlRwt031222
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 15:47:27 GMT
Received: from d12av04.megacenter.de.ibm.com (d12av04.megacenter.de.ibm.com [9.149.165.229])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m3BFlSVT4362308
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 17:47:28 +0200
Received: from d12av04.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av04.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m3BFlRVR019631
	for <netdev@vger.kernel.org>; Fri, 11 Apr 2008 17:47:27 +0200
In-Reply-To: <47FE2AD4.9080609@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Pavel Emelyanov wrote:
> Hi, guys.
> 
> I've recently sent a TUN devices virtualization, but it was rejected
> by Dave, since the struct net is becoming a dumping ground.
> 
> I agree with him - we really need some way to register on-net data
> dynamically. That's my view of such a thing and two examples of how
> to use it (TUN and VLAN devices virtualization).
> 
> If this will be found good, I'll send these sets to David, hoping he
> will accept them :)

Pavel,

seems to be a smart solution :)

I am just afraid with the performances when the network resources are to 
be accessed in the fast path like a routing table (that seems not to be 
the case for tun and vlan). Shall we assume the fast path should always 
go to struct net and non critical path can go to net_generic ?

   -- Daniel
