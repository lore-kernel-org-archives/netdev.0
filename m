From: Florian Westphal <fw@strlen.de>
Subject: Re: [[NET-NEXT]] Added dump function to recognise rpl extension
 header option(63)
Date: Thu, 4 May 2017 14:33:37 +0200
Message-ID: <20170504123337.GE13320@breakpoint.cc>
References: <a712ff423471e02a533650ce6d64dc85@ceid.upatras.gr>
 <af9727bf-9987-1046-c2aa-2a8695447fde@osg.samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andreas Bardoutsos <bardoutsos@ceid.upatras.gr>,
        netdev <netdev@vger.kernel.org>,
        Michael Richardson <mcr@sandelman.ca>,
        "linux-wpan@vger.kernel.org" <linux-wpan@vger.kernel.org>
To: Stefan Schmidt <stefan@osg.samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:56476 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750936AbdEDMeC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 4 May 2017 08:34:02 -0400
Content-Disposition: inline
In-Reply-To: <af9727bf-9987-1046-c2aa-2a8695447fde@osg.samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Schmidt <stefan@osg.samsung.com> wrote:
> ipv6: ext_header: add function to handle RPL option 0x63

But its not handled, is it?

The kernel tosses it because the RPL option/RFC says so
('nodes that do not understand this option on a received
 packet MUST discard the packet.').
