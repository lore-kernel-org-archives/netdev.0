From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE] iproute2-2.6.23-rc3
Date: Sat, 01 Sep 2007 09:12:41 +0200
Message-ID: <46D910E9.1040909@trash.net>
References: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net> <Pine.LNX.4.64.0708311112001.5681@x2> <46D7E0A4.2010404@openvz.org> <Pine.LNX.4.64.0708311144470.8423@x2> <46D7FEC2.4010902@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48340 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752635AbXIAHON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 03:14:13 -0400
In-Reply-To: <46D7FEC2.4010902@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Pavel Emelyanov wrote:
> Patrick McHardy wrote:
>> On Fri, 31 Aug 2007, Pavel Emelyanov wrote:
>>
>>>> Why does this add a new ip subcommand instead and uses genetlink
>>>> instead of the rtnl_link API, which was introduced exactly for
>>>> this stuff?
>>>>
>>> Hm... It does not, it just adds a parser for veth commands that
>>> generic layer isn't aware of.
>>
>> It does, you have "ip veth add", "ip veth del", ...
>>
>> Didn't you already sent a patch that used "ip link add ..."?
> 
> The patch I sent last used "ip link add" and "ip link del".
> The link_veth.c file only parses all the extra arguments.


Thats what I thought. I seems Stephen applied an old version of
the patch that still uses genetlink.

