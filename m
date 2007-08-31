From: Pavel Emelyanov <xemul@openvz.org>
Subject: Re: [ANNOUNCE] iproute2-2.6.23-rc3
Date: Fri, 31 Aug 2007 13:34:28 +0400
Message-ID: <46D7E0A4.2010404@openvz.org>
References: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net> <Pine.LNX.4.64.0708311112001.5681@x2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.233.200]:37798 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932526AbXHaJh1 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 31 Aug 2007 05:37:27 -0400
In-Reply-To: <Pine.LNX.4.64.0708311112001.5681@x2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> On Wed, 22 Aug 2007, Stephen Hemminger wrote:
> 
>> There have been a lot of changes for 2.6.23, so here is a test release
>> of iproute2 that should capture all the submitted patches
>>
>> Pavel Emelianov (1):
>>      Make ip utility veth driver aware
> 
> 
> Why does this add a new ip subcommand instead and uses genetlink
> instead of the rtnl_link API, which was introduced exactly for
> this stuff?
> 

Hm... It does not, it just adds a parser for veth commands that
generic layer isn't aware of.
