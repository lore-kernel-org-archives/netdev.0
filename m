From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: how to disable automatic route addition for an ipv6 address
Date: Tue, 6 Nov 2012 08:01:34 +0100 (CET)
Message-ID: <alpine.DEB.2.00.1211060755510.13802@uplift.swm.pp.se>
References: <CAHdPZaPt-ybmZiS5uzdos6OYC2q8BBmFfSgSQ0RnOe4AnPpcdA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: "devendra.aaru" <devendra.aaru@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:51911 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751805Ab2KFHBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Nov 2012 02:01:36 -0500
In-Reply-To: <CAHdPZaPt-ybmZiS5uzdos6OYC2q8BBmFfSgSQ0RnOe4AnPpcdA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 5 Nov 2012, devendra.aaru wrote:

> while adding the ipv6 address to interface ,
>
> ifconfig eth0 add 2001:8800:10fb:4444::ae/64
>
> i am seeing the route addition automatically
>
> route -n -A inet6 shows that one of the route from the above added address.

You mean you get a /64 route to the interface? I'd say that's normal, as 
you're adding a /64.

If you do not want this, add it as a /128 instead.

"ip -6 a a dev eth0 2000:db8::1/128" will add just that /128 to eth0 
interface without an encompassing network route.

"ip -6 r l" to verify (you will see just the IPv6 address to the device, 
ie an implicit /128).

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
