From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: HTB, HFSC, PIE, FIFO stuck on 2.4Gbit on default values
Date: Tue, 03 Nov 2015 20:28:37 -0800
Message-ID: <1446611317.4184.3.camel@edumazet-glaptop2.roam.corp.google.com>
References: <14bd7629199800f798c8ab932e0285d3@visp.net.lb>
	 <1446577894.23275.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <907cb54c0a27beed12381247ba29bca5@visp.net.lb>
	 <1446580156.23275.74.camel@edumazet-glaptop2.roam.corp.google.com>
	 <f970215bd46efe3ea3dc5c7fccfa0509@visp.net.lb>
	 <1446585826.23275.78.camel@edumazet-glaptop2.roam.corp.google.com>
	 <0394a0a8c8f65e367a596274719ed759@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36311 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754851AbbKDE2j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 23:28:39 -0500
Received: by pacdm15 with SMTP id dm15so15621902pac.3
        for <netdev@vger.kernel.org>; Tue, 03 Nov 2015 20:28:38 -0800 (PST)
In-Reply-To: <0394a0a8c8f65e367a596274719ed759@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-11-04 at 06:12 +0200, Denys Fedoryshchenko wrote:
> Just enabling gro or gso (or together) is fine there. Thanks for advice. 
> Seems only tso causing problems.
> Also i guess if i keep tso disabled, it will solve my MTU issues (i had 
> once issue, that traffic heading to pppoe users,
> who have 14xx mtu, was blocked, when offloading enabled on transit 
> server, but can't reproduce it quickly again).
> Should i try to report to e1000e maintainers this bug? On similar setup 
> it is happening only at specific locations,
> but i am not definitely sure what can be the reason.

Not sure, have you tried per chance latest kernel (linux-4.3) for this
e1000e issue ?

Are you using vlan tags on this NIC ?
