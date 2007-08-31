From: Patrick McHardy <kaber@trash.net>
Subject: Re: [ANNOUNCE] iproute2-2.6.23-rc3
Date: Fri, 31 Aug 2007 11:45:27 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0708311144470.8423@x2>
References: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net>
 <Pine.LNX.4.64.0708311112001.5681@x2> <46D7E0A4.2010404@openvz.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Pavel Emelyanov <xemul@openvz.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:54163 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932269AbXHaJqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Aug 2007 05:46:37 -0400
In-Reply-To: <46D7E0A4.2010404@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 31 Aug 2007, Pavel Emelyanov wrote:

> Patrick McHardy wrote:
>> On Wed, 22 Aug 2007, Stephen Hemminger wrote:
>>
>>> There have been a lot of changes for 2.6.23, so here is a test release
>>> of iproute2 that should capture all the submitted patches
>>>
>>> Pavel Emelianov (1):
>>>      Make ip utility veth driver aware
>>
>>
>> Why does this add a new ip subcommand instead and uses genetlink
>> instead of the rtnl_link API, which was introduced exactly for
>> this stuff?
>>
>
> Hm... It does not, it just adds a parser for veth commands that
> generic layer isn't aware of.


It does, you have "ip veth add", "ip veth del", ...

Didn't you already sent a patch that used "ip link add ..."?

In any case this should be replaced by proper use of the rtnl_link
stuff.
