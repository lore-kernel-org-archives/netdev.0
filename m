From: Richard Alpe <richard.alpe@ericsson.com>
Subject: Re: [PATCH v2 net-next 15/15] tipc: remove old ASCII netlink API
Date: Wed, 8 Oct 2014 14:02:30 +0200
Message-ID: <543527D6.2060607@ericsson.com>
References: <1412261921-28510-16-git-send-email-richard.alpe@ericsson.com>	<20141003.165038.2121547250200790300.davem@davemloft.net>	<A2BAEFC30C8FD34388F02C9B3121859D1C2EB615@eusaamb103.ericsson.se> <20141006.152003.1261907320590776614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>
To: David Miller <davem@davemloft.net>, <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sessmg22.ericsson.net ([193.180.251.58]:65520 "EHLO
	sessmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754555AbaJHMED (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 08:04:03 -0400
In-Reply-To: <20141006.152003.1261907320590776614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2014 09:20 PM, David Miller wrote:
> From: Jon Maloy <jon.maloy@ericsson.com>
> Date: Mon, 6 Oct 2014 13:37:14 +0000
>
>> I disagree.  We did of course consider this before we posted the patch.
>> There is absolutely no reason to believe there are binaries "out there"
>> using this API. It is intended for and used only by our own tool "tipc-config",
>> and the half-baked documentation that exists about it is not even
>> correct. This is an TIPC-internal API/ABI, which has changed over the years,
>> and keeps changing.  To our best judgement there is no risk in removing the
>> old API.
>>
>> However, we took great care to not break any scripts that might be using
>> tipc-config. Therefore, we made this wrapper that provides the old
>> tipc-config command API to existing users.
>
> A user should be able to upgrade the kernel and keep using tipc-config
> (or _whatever_) that's on their machine.
>
> You cannot break old stuff like this, and just because I didn't notice
> you slipping in incompatible changes in the past doesn't mean I'm going
> to let you keep doing it.
>
> Backwards compatability must be maintained for every single interface
> exposed to the user, and this is non-negotiable, sorry.
Alright. Can we log a deprecated warning when using the old API and 
eventually phase it out?

Regards
Richard
