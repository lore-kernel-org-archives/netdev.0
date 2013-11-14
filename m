From: Rami Rosen <roszenrami@gmail.com>
Subject: Re: network namespaces usage in routing appplications with VRF-like features
Date: Thu, 14 Nov 2013 13:18:00 +0200
Message-ID: <CAKoUArm6tjjSkLuno-5ZoCJ+mA8bLdoFExHXNFSpb6OXKz=_Bg@mail.gmail.com>
References: <292D0115604A314481EE77AB54A844C5672403D2@CMP-EX-DB3.cmpsys.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jacob Avraham <Jacob.Avraham@compass-eos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f182.google.com ([209.85.212.182]:59368 "EHLO
	mail-wi0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753146Ab3KNLSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 06:18:01 -0500
Received: by mail-wi0-f182.google.com with SMTP id i19so2195102wiw.9
        for <netdev@vger.kernel.org>; Thu, 14 Nov 2013 03:18:00 -0800 (PST)
In-Reply-To: <292D0115604A314481EE77AB54A844C5672403D2@CMP-EX-DB3.cmpsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
>  Does RTNETLINK API support adding routes to a particular namespace routing table?
No, at least not directly (though there are cases where you can
specify a network device the  RTNETLINK API requests. And in network
namespaces, a network device can belong only to one network namespace
at a given moment. But I am not sure if it is enough for your needs)

Regards,
Rami Rosen
http://ramirose.wix.com/ramirosen



On Wed, Nov 13, 2013 at 2:56 PM, Jacob Avraham
<Jacob.Avraham@compass-eos.com> wrote:
> Hi,
> I'm trying to evaluate the use of network namespaces in some routing applications, which are currently based on the VFR patchset.
> I was thinking about distributing several interfaces among a few namespaces, whereby each namespace has its own routing table(s), ala VRF.
> The questions that I have are:
> 1. Can I open a listening socket that accepts traffic from all interfaces in all namespaces? That's the current behavior of my routing protocol daemons.
> 2.   Does RTNETLINK API support adding routes to a particular namespace routing table?
>
> Thanks,
> Jacob
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
