From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [ANNOUNCE] iproute2-2.6.23-rc3
Date: Fri, 31 Aug 2007 15:42:58 +0400
Message-ID: <46D7FEC2.4010902@openvz.org>
References: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net> <Pine.LNX.4.64.0708311112001.5681@x2> <46D7E0A4.2010404@openvz.org> <Pine.LNX.4.64.0708311144470.8423@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:45670 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932419AbXHaLpv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 07:45:51 -0400
In-Reply-To: <Pine.LNX.4.64.0708311144470.8423@x2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> On Fri, 31 Aug 2007, Pavel Emelyanov wrote:
> 
>> Patrick McHardy wrote:
>>> On Wed, 22 Aug 2007, Stephen Hemminger wrote:
>>>
>>>> There have been a lot of changes for 2.6.23, so here is a test release
>>>> of iproute2 that should capture all the submitted patches
>>>>
>>>> Pavel Emelianov (1):
>>>>      Make ip utility veth driver aware
>>>
>>> Why does this add a new ip subcommand instead and uses genetlink
>>> instead of the rtnl_link API, which was introduced exactly for
>>> this stuff?
>>>
>> Hm... It does not, it just adds a parser for veth commands that
>> generic layer isn't aware of.
> 
> 
> It does, you have "ip veth add", "ip veth del", ...
> 
> Didn't you already sent a patch that used "ip link add ..."?

The patch I sent last used "ip link add" and "ip link del".
The link_veth.c file only parses all the extra arguments.

> In any case this should be replaced by proper use of the rtnl_link
> stuff.
> 

