From: Stefan Schmidt <stefan@osg.samsung.com>
Subject: Re: [[NET-NEXT]] Added dump function to recognise rpl extension
 header option(63)
Date: Thu, 4 May 2017 14:51:01 +0200
Message-ID: <20170504125101.GD31463@work.Speedport_W_724V_09011603_05_010>
References: <a712ff423471e02a533650ce6d64dc85@ceid.upatras.gr>
 <af9727bf-9987-1046-c2aa-2a8695447fde@osg.samsung.com>
 <20170504123337.GE13320@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Schmidt <stefan@osg.samsung.com>,
        Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>,
        netdev <netdev@vger.kernel.org>,
        Michael Richardson <mcr@sandelman.ca>,
        "linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ec2-52-27-115-49.us-west-2.compute.amazonaws.com ([52.27.115.49]:52896
        "EHLO osg.samsung.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1750848AbdEDMvJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 08:51:09 -0400
Content-Disposition: inline
In-Reply-To: <20170504123337.GE13320@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On Thu, 2017-05-04 at 14:33, Florian Westphal wrote:
> Stefan Schmidt <stefan@osg.samsung.com> wrote:
> > ipv6: ext_header: add function to handle RPL option 0x63
> 
> But its not handled, is it?

Its not handled in the kernel. The RPL daemon would run in userspace in this
case.

>From my understanding unstrung (or any other RPL implementation) needs this
packet. Right now the kernel silently drops it. Michael would know best
about the details here and if we need some more logic in the kernel itself.
Maybe just some sanity checking of the TLV.

> The kernel tosses it because the RPL option/RFC says so
> ('nodes that do not understand this option on a received
>  packet MUST discard the packet.').

What we might need is a way to let the kernel know we have a RPL running with
support for this option. Would that meet your concern?

regards
Stefan Schmidt
