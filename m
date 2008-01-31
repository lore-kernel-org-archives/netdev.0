From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] Disable TSO for non standard qdiscs
Date: Thu, 31 Jan 2008 21:33:44 +0100
Message-ID: <47A230A8.7080100@gmail.com>
References: <20080131124632.GA25299@basil.nowhere.org> <20080131092327.75b9c369@extreme> <20080131183322.GA4671@one.firstfloor.org> <47A20CDC.5090104@trash.net> <20080131183735.GC4671@one.firstfloor.org> <20080131100846.00934e25@extreme> <20080131185328.GD4671@one.firstfloor.org> <47A211A0.1040502@trash.net> <20080131190125.GE4671@one.firstfloor.org> <D5C1322C3E673F459512FB59E0DDC32904700E40@orsmsx414.amr.corp.intel.com> <20080131193406.GH4671@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.172]:26221 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753996AbYAaUaY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jan 2008 15:30:24 -0500
Received: by ug-out-1314.google.com with SMTP id z38so624550ugc.16
        for <netdev@vger.kernel.org>; Thu, 31 Jan 2008 12:30:23 -0800 (PST)
In-Reply-To: <20080131193406.GH4671@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote, On 01/31/2008 08:34 PM:

>> TSO by nature is bursty.  But disabling TSO without the option of having
>> it on or off to me seems to aggressive.  If someone is using a qdisc
>> that TSO is interfering with the effectiveness of the traffic shaping,
>> then they should turn off TSO via ethtool on the target device.  Some
> 
> The philosophical problem I have with this suggestion is that I expect
> that the large majority of users will be more happy with disabled TSO
> if they use non standard qdiscs and defaults that do not fit 
> the majority use case are bad.


If you mean the large majority of the large minority of users, who use
non standard qdiscs - I agree - this is really the philosophical problem!

 
> Basically you're suggesting that nearly everyone using tc should learn about
> another obscure command.

...So, it sounds like tc is used by nearly everyone now...

It seems my distro really isn't up to date:

"Package: iproute
 ...
 Description: Professional tools to control the networking in Linux kernels
 This is `iproute', the professional set of tools to control the
 networking behavior in kernels 2.2.x and later."

And ethtool doesn't have to be learnt at all: "most friendly distros"
could use this in config or add some graphical wrapper.

Regards,
Jarek P.
