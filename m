From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: PATCH WAS( Re: [ANNOUNCE] iproute2 v2.6.25
Date: Fri, 18 Apr 2008 17:59:41 -0700
Message-ID: <20080418175941.2ae6506f@extreme>
References: <20080417103858.0075236b@extreme>
	<1208464539.15888.22.camel@localhost>
	<20080417134656.761748d4@extreme>
	<1208465951.15888.33.camel@localhost>
	<20080417140837.1e92b449@extreme>
	<1208467480.15888.50.camel@localhost>
	<1208522727.4422.79.camel@localhost>
	<4808AEBF.7040504@trash.net>
	<1208563696.4450.43.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:37275 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750934AbYDSA7u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Apr 2008 20:59:50 -0400
In-Reply-To: <1208563696.4450.43.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 18 Apr 2008 20:08:16 -0400
jamal <hadi@cyberus.ca> wrote:

> On Fri, 2008-18-04 at 16:22 +0200, Patrick McHardy wrote:
> 
> > 
> > Yes, that sucks (ran into the same problem with iproute in a
> > previous job). I added the ENV dump format to libnl a couple
> > of years ago (NAME=val), should be easy to add a set of simple
> > tools to get the information and export it in the environment.
> 
> Can you explain this a little? Would these variables define what
> the command line parameters look like before invoking?
> 
> cheers,
> jamal
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

If somebody doesn't do it first, maybe split the u32 output into:
	(nothing) original format
	-raw	  value/offset
	-pretty	  decoded equivalent of original command

