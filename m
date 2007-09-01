From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [ANNOUNCE] iproute2-2.6.23-rc3
Date: Sat, 1 Sep 2007 13:56:19 +0100
Message-ID: <20070901135619.239b6d45@oldman>
References: <20070822110804.30c2e803@freepuppy.rosehill.hemminger.net>
	<Pine.LNX.4.64.0708311112001.5681@x2>
	<46D7E0A4.2010404@openvz.org>
	<Pine.LNX.4.64.0708311144470.8423@x2>
	<46D7FEC2.4010902@openvz.org>
	<46D910E9.1040909@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Pavel Emelyanov <xemul@openvz.org>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:42159 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750965AbXIAMzx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Sep 2007 08:55:53 -0400
In-Reply-To: <46D910E9.1040909@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 01 Sep 2007 09:12:41 +0200
Patrick McHardy <kaber@trash.net> wrote:

> Pavel Emelyanov wrote:
> > Patrick McHardy wrote:
> >> On Fri, 31 Aug 2007, Pavel Emelyanov wrote:
> >>
> >>>> Why does this add a new ip subcommand instead and uses genetlink
> >>>> instead of the rtnl_link API, which was introduced exactly for
> >>>> this stuff?
> >>>>
> >>> Hm... It does not, it just adds a parser for veth commands that
> >>> generic layer isn't aware of.
> >>
> >> It does, you have "ip veth add", "ip veth del", ...
> >>
> >> Didn't you already sent a patch that used "ip link add ..."?
> > 
> > The patch I sent last used "ip link add" and "ip link del".
> > The link_veth.c file only parses all the extra arguments.
> 
> 
> Thats what I thought. I seems Stephen applied an old version of
> the patch that still uses genetlink.
> 

Send me a new one, and I'll revert the old one.
