From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] ipv6: skip __ipv6_select_ident when there is no
 skb_dst
Date: Thu, 19 Mar 2015 11:10:36 +0100
Message-ID: <20150319101036.GA10040@kria>
References: <1426686735-6129-1-git-send-email-sd@queasysnail.net>
 <550985DA.3070703@redhat.com>
 <20150318141529.GD1743@kria>
 <55098AE7.2020404@redhat.com>
 <20150318143644.GE1743@kria>
 <1426757990.10267.3.camel@mattgrant.net.nz>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Vlad Yasevich <vyasevic@redhat.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Matt Grant <matt@mattgrant.net.nz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:45931 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751130AbbCSKKn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 19 Mar 2015 06:10:43 -0400
Content-Disposition: inline
In-Reply-To: <1426757990.10267.3.camel@mattgrant.net.nz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-03-19, 22:39:50 +1300, Matt Grant wrote:
> Hi!
> 
> This fixes hard lock on 3.19.2 as well. Without it, machine drops dead -
> hard locks - pretty quickly after boot.
> 
> Will try 4.0-rc4 tomorrow.  4.0-rc3 had same hard crash issues.
> 
> Get it out there, this is a IPv6 network Packet of Death!  We need
> 3.19.3 ASAP I think.  
> 
> I'll try and see if I can get a network trace of the cause on Saturday.
> 
> Regards,
> 
> Matt

Thanks for testing this, Matt.
I will submit the patch in a few minutes.

-- 
Sabrina
