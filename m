From: Florian Fainelli <florian.fainelli@int-evry.fr>
Subject: Re: Network activity LED trigger
Date: Fri, 2 Mar 2007 13:58:51 +0100
Message-ID: <200703021358.52224.florian.fainelli@int-evry.fr>
References: <200703012241.49165.florian.fainelli@int-evry.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Richard Purdie <rpurdie@rpsys.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-ext.int-evry.fr ([157.159.11.17]:40973 "EHLO
	smtp-ext.int-evry.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1945916AbXCBM73 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Mar 2007 07:59:29 -0500
In-Reply-To: <200703012241.49165.florian.fainelli@int-evry.fr>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All,

Some more thoughts. The IDE activity LED trigger is currently triggered=
 when a=20
function is called in the IDE writing/reading routines.

In a similar way, we could call the trigger function in net/core/dev.c =
in=20
netif_receive_skb and netif_rx ?

I was also thinking that some network NIC already have LEDs, so it is n=
ot=20
necessary for those models to "overload" the user with lights everywher=
e.

Regars, Florian

Le jeudi 1 mars 2007, Florian Fainelli a =C3=A9crit=C2=A0:
> Hi All,
>
> I have been talking a bit with Richard, who is the LED API maintainer=
, and
> a LED trigger based on network activity would be something great.
>
> There are somethings that concern the network stack :
>
> - should we specify if the network driver is allowed to contribute to
> the LED activity, just like it is done for random generation, at comp=
ile
> time
>
> - I would like to trigger the LED based on one or several network
> interfaces, maybe specify via sysfs which interface triggers which LE=
D,
> and also maybe differentiate the layer-2 activity from the layer-3
> activity for instance
>
> - A led driver could by default be bound to a network driver, or an
> interface name
>
> As it could be very intrusive in the network stack, you might want to
> specify a bit more how you imagine a network activity trigger.
>
> Thanks
