From: =?UTF-8?B?Tmljb2xhcyBkZSBQZXNsb8O8YW4=?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Fri, 02 Sep 2011 23:39:03 +0200
Message-ID: <4E614CF7.7030700@gmail.com>
References: <20110902172220.830228928@vyatta.com> <20110902172247.396753508@vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:39467 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756127Ab1IBVjD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 17:39:03 -0400
Received: by wyh22 with SMTP id 22so2288595wyh.19
        for <netdev@vger.kernel.org>; Fri, 02 Sep 2011 14:39:00 -0700 (PDT)
In-Reply-To: <20110902172247.396753508@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/09/2011 19:22, Stephen Hemminger a =C3=A9crit :
> This resolves a regression seen by some users of bridging.
> Some users use the bridge like a dummy device.
> They expect to be able to put an IPv6 address on the device
> with no ports attached during boot.
>
> Note: the bridge still will reflect the state of ports in the
> bridge if there are any added.

Doesn't this jeopardize the behavior introduced in 1faa4356a3bd89ea11fb=
92752d897cff3a20ec0e
"bridge: control carrier based on ports online"?

If the user starts the DHCP client before adding the first port to the =
bridge, the DHCP client will=20
have a carrier and start the autoconfiguration process. This was the ol=
d behavior, but you fixed it.

	Nicolas.
