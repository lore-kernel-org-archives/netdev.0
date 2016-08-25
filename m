From: Florian Westphal <fw@strlen.de>
Subject: Re: [RFC 1/3] tcp: randomize tcp timestamp offsets for each
 connection
Date: Thu, 25 Aug 2016 22:31:25 +0200
Message-ID: <20160825203125.GA10987@breakpoint.cc>
References: <1471524527-10029-1-git-send-email-fw@strlen.de>
 <1471524527-10029-2-git-send-email-fw@strlen.de>
 <1472153655.14381.152.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Westphal <fw@strlen.de>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:51564 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932544AbcHYUb2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 16:31:28 -0400
Content-Disposition: inline
In-Reply-To: <1472153655.14381.152.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Thu, 2016-08-18 at 14:48 +0200, Florian Westphal wrote:
> It seems tcp_v4_reqsk_send_ack() and tcp_v6_reqsk_send_ack() were not
> taken into account.
> 
> See commit 20a2b49fc5385 changelog
> packetdrill test showing the possible issue if the TS sent on an ACK in
> SYN_RECV state is wrong.

Thanks a lot Eric, I'll fix this.
